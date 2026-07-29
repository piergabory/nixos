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
  '';

  # Deliberately not placed in /etc/ssh/ssh_config. OpenSSH reads the invoking
  # user's ~/.ssh/config first and the first value obtained for a keyword wins,
  # so any `Host *` block in root's dotfiles silently overrides a system-wide
  # setting. home-manager writes exactly such a block. Forcing -F here makes
  # these services depend only on the Nix store.
  #
  # Named `ssh` and placed at the front of the unit PATH because restic's sftp
  # backend shells out to whichever `ssh` it finds there.
  sshWrapper = pkgs.writeShellScriptBin "ssh" ''
    exec ${pkgs.openssh}/bin/ssh -F ${sshConfig} "$@"
  '';

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

        if ! ${restic} -r ${cfg.repository} \
              --password-file ${cfg.passwordFile} \
              cat config > /dev/null 2>&1; then
          echo "Replica does not exist yet, initialising it."
          ${restic} -r ${cfg.repository} --password-file ${cfg.passwordFile} init
        fi

        # copy, not sync: snapshots already replicated are skipped, and
        # snapshots deleted upstream stay here until this machine's own
        # retention policy expires them.
        ${restic} -r ${cfg.repository} \
          --password-file ${cfg.passwordFile} \
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
