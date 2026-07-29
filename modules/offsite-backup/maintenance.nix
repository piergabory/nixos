{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;
  restic = "${pkgs.restic}/bin/restic";

  resticEnv = {
    Type = "oneshot";
    TimeoutStartSec = "infinity";
    Nice = 15;
    IOSchedulingClass = "idle";

    # systemd units start with no HOME, and restic refuses to run without
    # somewhere to put its cache.
    CacheDirectory = "offsite-backup";
    Environment = [ "RESTIC_CACHE_DIR=/var/cache/offsite-backup" ];
  };

  mountCondition = optionalAttrs (cfg.dataDisk.device != null) {
    RequiresMountsFor = cfg.dataDisk.mountPoint;
    ConditionPathIsMountPoint = cfg.dataDisk.mountPoint;
  };
in
{
  config = mkIf cfg.enable {
    systemd.services.offsite-backup-prune = {
      description = "Expire and repack the replicated backup repository";
      after = [ "offsite-backup-pull.service" ];
      unitConfig = mountCondition;
      serviceConfig = resticEnv;

      script = ''
        set -euo pipefail
        ${restic} -r ${cfg.repository} \
          --password-file ${cfg.passwordFile} \
          forget --prune ${concatStringsSep " " cfg.pruneOpts}
      '';
    };

    systemd.services.offsite-backup-check = {
      description = "Verify the integrity of the replicated backup repository";
      unitConfig = mountCondition;
      serviceConfig = resticEnv;

      # Re-hashes a rotating fraction of the pack files. On an ageing drive,
      # silent corruption is otherwise only discovered during a restore, which
      # is precisely the wrong moment.
      script = ''
        set -euo pipefail
        ${restic} -r ${cfg.repository} \
          --password-file ${cfg.passwordFile} \
          check --read-data-subset=${cfg.maintenance.checkSubset}
      '';
    };

    systemd.timers.offsite-backup-prune = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.maintenance.pruneOnCalendar;
        RandomizedDelaySec = "2h";
        Persistent = true;
        Unit = "offsite-backup-prune.service";
      };
    };

    systemd.timers.offsite-backup-check = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.maintenance.checkOnCalendar;
        RandomizedDelaySec = "2h";
        Persistent = true;
        Unit = "offsite-backup-check.service";
      };
    };

    # The root filesystem is a small, cheap SSD. Left alone, generations and
    # the store will fill it and the machine becomes unrecoverable remotely.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    nix.settings.auto-optimise-store = true;
    boot.loader.systemd-boot.configurationLimit = mkDefault 10;

    environment.systemPackages = [ pkgs.restic ];
  };
}
