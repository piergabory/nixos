{ config, lib, ... }:
with lib;

let
  cfg = config.services.vaultwarden;
in {
  config = mkIf cfg.enable {
    services.restic.backups.vaultwarden = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;
      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "03:20";
      };
      paths = [
        "/var/backup/vaultwarden"
      ];
      backupPrepareCommand = ''
        ${config.systemd.package}/bin/systemctl start backup-vaultwarden.service
      '';
      extraBackupArgs = [
        "--tag vaultwarden"
        "--one-file-system"
      ];
    };
  };
}
