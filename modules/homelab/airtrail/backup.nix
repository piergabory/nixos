{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.airtrail;
in {
  config = mkIf cfg.enable {
    services.restic.backups.airtrail = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;
      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "04:20";
      };
      paths = [
        "/var/backup/restic/airtrail"
        "/var/lib/airtrail/uploads"
      ];
      backupPrepareCommand = ''
        rm -rf /var/backup/restic/airtrail
        mkdir -p /var/backup/restic/airtrail
        set -a
        . ${config.age.secrets.airtrail-env.path}
        set +a
        ${pkgs.podman}/bin/podman exec airtrail-db pg_dump \
          -U "''${DB_USERNAME:-airtrail}" "''${DB_DATABASE_NAME:-airtrail}" \
          > /var/backup/restic/airtrail/airtrail.sql
      '';
      extraBackupArgs = [
        "--tag airtrail"
        "--one-file-system"
      ];
    };
  };
}
