{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.dawarich;
in {
  config = mkIf cfg.enable {
      services.restic.backups.dawarich = {
      inherit (config.piergabory.backups) repository passwordFile pruneOpts;

      initialize = true;

      timerConfig = config.piergabory.backups.timerConfig // {
        OnCalendar = "04:10";
      };

      paths = [ "/var/backup/restic/dawarich" ];

      backupPrepareCommand = ''
        rm -rf /var/backup/restic/dawarich
        mkdir -p /var/backup/restic/dawarich
        ${pkgs.util-linux}/bin/runuser -u postgres \
          -- ${config.services.postgresql.package}/bin/pg_dump dawarich \
          > /var/backup/restic/dawarich/dawarich.sql
      '';

      extraBackupArgs = [
        "--tag dawarich"
        "--one-file-system"
      ];
    };
  };
}
