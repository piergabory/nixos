{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkOption
    types
    mapAttrs'
    nameValuePair
    concatStringsSep
    ;

  cfg = config.services.backups;
in

{
  options.services.backups = {
    group = mkOption {
      type = types.str;
      default = "restic";
      description = ''
        Group granted read access to the repository. Restic jobs run as root
        and would otherwise create pack files as 0600 root, unreadable by the
        offsite replica user.
      '';
    };

    repository = mkOption {
      type = types.str;
      default = "/storage/backups/restic/workstation";
      description = "Local restic repository for workstation service backups.";
    };

    passwordFile = mkOption {
      type = types.str;
      default = config.age.secrets.restic-password.path;
      description = "Path to the restic repository password file.";
    };

    timerConfig = mkOption {
      type = types.attrs;
      default = {
        OnCalendar = "03:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
      description = "Default timer configuration for restic backups.";
    };

    pruneOpts = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Per-job retention. Deliberately empty: pruning takes an exclusive lock
        on the repository, so a job that prunes fails whenever another job is
        still running. That was survivable while every job finished in seconds,
        but the Immich job runs for hours and overlaps all the others. Retention
        is applied once, centrally, by restic-prune instead. See `retention`.
      '';
    };

    retention = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
      ];
      description = "Retention policy applied by the central prune job.";
    };

    pruneTimerConfig = mkOption {
      type = types.attrs;
      default = {
        OnCalendar = "06:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
      description = ''
        When to expire snapshots. Should sit after every backup job has had a
        chance to finish.
      '';
    };
  };

  config = {
    users.groups.${cfg.group} = { };

    # Restic runs as root. Without a relaxed umask the repository is only
    # readable by root, which defeats the point of a dedicated replica user.
    # Combined with the setgid bit below, every new pack file lands in the
    # backup group with group read/write.
    systemd.services = mapAttrs' (
      name: _:
      nameValuePair "restic-backups-${name}" {
        serviceConfig.UMask = "0007";
      }
    ) config.services.restic.backups
    // {
      # One prune for the whole repository rather than one per job: it needs an
      # exclusive lock, and it is wasted work to repeat it a dozen times a night.
      restic-prune = {
        description = "Expire and repack the backup repository";

        serviceConfig = {
          Type = "oneshot";
          UMask = "0007";
          Nice = 15;
          IOSchedulingClass = "idle";
          TimeoutStartSec = "infinity";

          # If a long-running backup still holds the lock, come back later
          # rather than skipping retention for the day.
          Restart = "on-failure";
          RestartSec = "30m";
        };

        unitConfig.StartLimitIntervalSec = 0;

        script = ''
          set -euo pipefail
          ${pkgs.restic}/bin/restic \
            -r ${cfg.repository} \
            --password-file ${cfg.passwordFile} \
            forget --prune ${concatStringsSep " " cfg.retention}
        '';
      };
    };

    systemd.timers.restic-prune = {
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.pruneTimerConfig // {
        Unit = "restic-prune.service";
      };
    };

    systemd.tmpfiles.rules = [
      # 0751 on the two parents: traversable, but not listable, by the
      # replica user. /storage/backups/restic doubles as its SSH chroot, so it
      # must stay root-owned and not writable by group or other.
      "d /storage/backups 0751 root root -"
      "d /storage/backups/restic 0751 root root -"
      "d /storage/backups/restic/workstation 2770 root ${cfg.group} -"
      "d /var/backup/restic 0700 root root -"
    ];
  };
}
