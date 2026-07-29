{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;

  sourceAlias = "offsite-backup-source";
  tunnelAlias = "offsite-backup-tunnel";

  # Keyed on the aliases rather than the hostname, so the pin survives this
  # machine moving between networks and the name resolving to a different
  # address at home than it does anywhere else.
  knownHosts = pkgs.writeText "offsite-known-hosts" ''
    ${sourceAlias} ${cfg.source.hostKey}
    ${tunnelAlias} ${cfg.source.hostKey}
    ${cfg.report.alias} ${cfg.source.hostKey}
  '';

  sshConfig = pkgs.writeText "offsite-ssh-config" ''
    Host ${sourceAlias}
      HostName ${cfg.source.host}
      Port ${toString cfg.source.port}
      User ${cfg.source.user}
      IdentityFile ${cfg.source.identityFile}
      IdentitiesOnly yes
      HostKeyAlias ${sourceAlias}
      UserKnownHostsFile ${knownHosts}
      GlobalKnownHostsFile /dev/null
      StrictHostKeyChecking yes
      BatchMode yes
      ServerAliveInterval 30
      ServerAliveCountMax 3

    Host ${tunnelAlias}
      HostName ${cfg.tunnel.host}
      Port ${toString cfg.tunnel.port}
      User ${cfg.tunnel.user}
      IdentityFile ${cfg.source.identityFile}
      IdentitiesOnly yes
      HostKeyAlias ${tunnelAlias}
      UserKnownHostsFile ${knownHosts}
      GlobalKnownHostsFile /dev/null
      StrictHostKeyChecking yes
      BatchMode yes
      ExitOnForwardFailure yes
      ServerAliveInterval 30
      ServerAliveCountMax 3

    Host ${cfg.report.alias}
      HostName ${cfg.source.host}
      Port ${toString cfg.source.port}
      User ${cfg.report.user}
      IdentityFile ${cfg.source.identityFile}
      IdentitiesOnly yes
      HostKeyAlias ${cfg.report.alias}
      UserKnownHostsFile ${knownHosts}
      GlobalKnownHostsFile /dev/null
      StrictHostKeyChecking yes
      BatchMode yes
  '';

  # Deliberately not placed in /etc/ssh/ssh_config. OpenSSH reads the invoking
  # user's ~/.ssh/config first and the first value obtained for a keyword wins,
  # so any `Host *` block in root's dotfiles silently overrides a system-wide
  # setting. home-manager writes exactly such a block. Forcing -F here makes
  # these services depend only on the Nix store.
  sshWrapper = pkgs.writeShellScriptBin "ssh" ''
    exec ${pkgs.openssh}/bin/ssh -F ${sshConfig} "$@"
  '';

  # restic's sftp backend shells out to `ssh`, but the nixpkgs wrapper prefixes
  # PATH with its own openssh, so the wrapper above can never win by ordering.
  # Name the command explicitly instead. Only the source repository uses sftp;
  # the replica is a local path, so this cannot affect it.
  sftpCommand = "${sshWrapper}/bin/ssh ${sourceAlias} -s sftp";

  sourceRepository = "sftp:${sourceAlias}:${cfg.source.path}";

  restic = "${pkgs.restic}/bin/restic";
in
{
  options.modules.offsiteBackup.sshWrapper = mkOption {
    type = types.package;
    internal = true;
    default = sshWrapper;
    description = "ssh pinned to the backup-specific configuration.";
  };

  config = mkIf cfg.enable {
    systemd.services.offsite-backup-pull = {
      description = "Replicate the home-lab backup repository";

      # This is a Type=oneshot that can legitimately run for hours. Left to its
      # default, nixos-rebuild would restart it on every switch and then block
      # waiting for the copy to finish, which makes the machine impossible to
      # update while it is working. The timer decides when it runs; a
      # configuration change simply takes effect on the next run.
      restartIfChanged = false;
      stopIfChanged = false;

      after = [
        "network-online.target"
        "offsite-backup-storage.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "offsite-backup-storage.service" ];

      # Order matters: the wrapper must shadow the real ssh for restic.
      path = [
        sshWrapper
        pkgs.openssh
        pkgs.restic
      ];

      serviceConfig = {
        Type = "oneshot";

        # systemd units start with no HOME, and restic refuses to run without
        # somewhere to put its cache. A persistent cache also keeps repeat
        # copies cheap, so this is not merely to silence an error.
        CacheDirectory = "offsite-backup";
        Environment = [ "RESTIC_CACHE_DIR=/var/cache/offsite-backup" ];

        # Seeding this repository means moving a couple of hundred gigabytes
        # over a home uplink. There is no meaningful upper bound to set.
        TimeoutStartSec = "infinity";

        # A dropped link mid-transfer is expected, not exceptional. Retry
        # patiently; restic resumes from the snapshots already copied.
        Restart = "on-failure";
        RestartSec = "1h";

        Nice = 10;
        IOSchedulingClass = "idle";
      };

      unitConfig = {
        StartLimitIntervalSec = 0;
      }
      // optionalAttrs (cfg.dataDisk.device != null) {
        RequiresMountsFor = cfg.dataDisk.mountPoint;
        ConditionPathIsMountPoint = cfg.dataDisk.mountPoint;
      };

      script = ''
        set -euo pipefail

        # A plain file test rather than asking restic: the replica is a local
        # path, and `restic cat config` reports failure for reasons unrelated
        # to existence, which led to init being run against a repository that
        # was already there.
        if [ ! -e ${cfg.repository}/config ]; then
          echo "Replica does not exist yet, initialising it."
          ${restic} -r ${cfg.repository} --password-file ${cfg.passwordFile} init
        fi

        # Fail loudly and early if the replica cannot be opened, rather than
        # letting a password mismatch surface as an obscure copy error.
        ${restic} -r ${cfg.repository} --password-file ${cfg.passwordFile} cat config > /dev/null

        # copy, not sync: snapshots already replicated are skipped, and
        # snapshots deleted upstream stay here until this machine's own
        # retention policy expires them.
        ${restic} -r ${cfg.repository} \
          --password-file ${cfg.passwordFile} \
          -o sftp.command="${sftpCommand}" \
          copy \
          --from-repo ${sourceRepository} \
          --from-password-file ${cfg.passwordFile}
      '';
    };

    systemd.timers.offsite-backup-pull = {
      description = "Schedule home-lab backup replication";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = cfg.schedule.onCalendar;
        RandomizedDelaySec = cfg.schedule.randomizedDelaySec;
        # Catches up after the machine has been powered off past a due run.
        Persistent = cfg.schedule.persistent;
        Unit = "offsite-backup-pull.service";
      };
    };
  };
}
