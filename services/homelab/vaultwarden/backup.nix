{ config, lib, ... }:
with lib;

let
  cfg = config.services.vaultwarden;
in {
  config = mkIf cfg.enable {
    services.restic.backups.vaultwarden = {
      inherit (config.piergabory.backups) repository passwordFile pruneOpts;
      initialize = true;
      timerConfig = config.piergabory.backups.timerConfig // {
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
