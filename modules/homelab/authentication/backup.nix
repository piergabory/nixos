{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.authentication;
in {
  config = mkIf cfg.enable {
    services.restic.backups.authelia = {
      inherit (config.services.backups) repository passwordFile pruneOpts;

      initialize = true;

      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "03:10";
      };

      paths = [ "/var/backup/restic/authelia" ];

      backupPrepareCommand = ''
        rm -rf /var/backup/restic/authelia
        mkdir -p /var/backup/restic/authelia
        ${pkgs.sqlite}/bin/sqlite3 /var/lib/authelia-main/db.sqlite3 ".backup '/var/backup/restic/authelia/db.sqlite3'"
      '';

      extraBackupArgs = [
        "--tag authelia"
        "--one-file-system"
      ];
    };
  };
}
