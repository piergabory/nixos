{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;

  sourceAlias = "offsite-backup-source";
  tunnelAlias = "offsite-backup-tunnel";

  # Keyed on the alias rather than the hostname, so the pin survives the
  # machine moving between networks and the name resolving to a different
  # address at home than it does anywhere else.
  knownHosts = pkgs.writeText "offsite-known-hosts" ''
    ${sourceAlias} ${cfg.source.hostKey}
    ${tunnelAlias} ${cfg.source.hostKey}
  '';

  sourceRepository = "sftp:${sourceAlias}:${cfg.source.path}";

  restic = "${pkgs.restic}/bin/restic";
in
{
  config = mkIf cfg.enable {
    # Aliases rather than a plain `Host pierr.re` block: the latter would also
    # rewrite interactive logins to the home-lab for every user on this machine.
    programs.ssh.extraConfig = ''
      Host ${sourceAlias}
        HostName ${cfg.source.host}
        Port ${toString cfg.source.port}
        User ${cfg.source.user}
        IdentityFile ${cfg.source.identityFile}
        IdentitiesOnly yes
        HostKeyAlias ${sourceAlias}
        UserKnownHostsFile ${knownHosts}
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
        StrictHostKeyChecking yes
        BatchMode yes
        ExitOnForwardFailure yes
        ServerAliveInterval 30
        ServerAliveCountMax 3
    '';

    systemd.services.offsite-backup-pull = {
      description = "Replicate the home-lab backup repository";

      after = [
        "network-online.target"
        "offsite-restore-guide.service"
      ];
      wants = [ "network-online.target" ];

      path = [
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
      } // optionalAttrs (cfg.dataDisk.device != null) {
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
