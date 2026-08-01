{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    types
    mapAttrs'
    nameValuePair
    concatStringsSep
    ;

  homelab = config.modules.homelab;
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

  config = mkIf homelab.enable {
    users.groups.${cfg.group} = { };

    # Restoring is an emergency operation. Having to locate a Nix store path
    # before you can read your own backups is the wrong thing to discover
    # halfway through a disaster. sqlite is here for the same reason: half the
    # services store their data in it, and a restore is worth verifying.
    environment.systemPackages = [
      pkgs.restic
      pkgs.sqlite
    ];

    # Restic runs as root. Without a relaxed umask the repository is only
    # readable by root, which defeats the point of a dedicated replica user.
    # 0027 grants the backup group read, but not write: replication has been
    # verified to work against a fully read-only source, so a compromised
    # offsite machine cannot damage the originals it is copying from.
    systemd.services =
      mapAttrs' (
        name: _:
        nameValuePair "restic-backups-${name}" {
          serviceConfig.UMask = "0027";

          # These are Type=oneshot units that can run for hours; the Immich job
          # takes most of a night. Restarting them on switch would make
          # nixos-rebuild block until the backup finished. Their timers decide
          # when they run, so a change takes effect on the next run.
          restartIfChanged = false;
          stopIfChanged = false;
        }
      ) config.services.restic.backups
      // {
        # One prune for the whole repository rather than one per job: it needs an
        # exclusive lock, and it is wasted work to repeat it a dozen times a night.
        restic-prune = {
          description = "Expire and repack the backup repository";

          # Long-running oneshot: never let a rebuild block on it.
          restartIfChanged = false;
          stopIfChanged = false;

          serviceConfig = {
            Type = "oneshot";
            UMask = "0027";
            Nice = 15;
            IOSchedulingClass = "idle";
            TimeoutStartSec = "infinity";

            # systemd units start with no HOME, and restic refuses to run
            # without somewhere to put its cache.
            CacheDirectory = "restic-prune";
            Environment = [ "RESTIC_CACHE_DIR=/var/cache/restic-prune" ];

            # If a long-running backup still holds the lock, come back later
            # rather than skipping retention for the day.
            Restart = "on-failure";
            RestartSec = "30m";
          };

          unitConfig.StartLimitIntervalSec = 0;

          script = ''
            set -euo pipefail

            # A killed backup or a replica that lost power leaves its lock
            # behind, and restic only clears stale locks in the `unlock`
            # command -- acquiring a lock never does. Without this the retry
            # above spins every 30 minutes forever and retention silently
            # stops being applied; that went unnoticed for three days.
            #
            # Not --remove-all: plain unlock only drops locks whose owner is
            # provably gone. A live restic refreshes its lock every five
            # minutes, so the hours-long Immich job is never touched.
            ${pkgs.restic}/bin/restic \
              -r ${cfg.repository} \
              --password-file ${cfg.passwordFile} \
              unlock

            ${pkgs.restic}/bin/restic \
              -r ${cfg.repository} \
              --password-file ${cfg.passwordFile} \
              forget --prune ${concatStringsSep " " cfg.retention}
          '';
        };

        # The repository directories are created here rather than by
        # systemd.tmpfiles, which refuses to act on these paths with "unsafe path
        # transition /storage (owned by piergabory) -> /storage/backups (owned by
        # root)" and does so silently, so those rules never applied at all.
        restic-repository-permissions = {
          description = "Create the backup repository and enforce its permissions";
          wantedBy = [ "multi-user.target" ];
          before = map (name: "restic-backups-${name}.service") (
            builtins.attrNames config.services.restic.backups
          );

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = ''
            set -euo pipefail

            # Traversable, but not listable, by the replica user.
            install -d -m 0751 -o root -g root /storage/backups
            install -d -m 0751 -o root -g root /storage/backups/restic

            # setgid so new files inherit the backup group; group-readable but
            # not group-writable, so the replica cannot alter what it copies.
            install -d -m 2750 -o root -g ${cfg.group} ${cfg.repository}

            # The one exception. restic locks the source before copying, and that
            # lock is what stops the prune job from removing packs midway through
            # a replication, so it is worth having rather than suppressing.
            install -d -m 2770 -o root -g ${cfg.group} ${cfg.repository}/locks
          '';
        };
      };

    systemd.timers.restic-prune = {
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.pruneTimerConfig // {
        Unit = "restic-prune.service";
      };
    };

    # Deliberately not systemd.tmpfiles: it refuses to act on these paths with
    # "unsafe path transition /storage (owned by piergabory) -> /storage/backups
    # (owned by root)", and does so silently, so the rules never applied at all.
    systemd.tmpfiles.rules = [
      "d /var/backup/restic 0700 root root -"
    ];
  };
}
