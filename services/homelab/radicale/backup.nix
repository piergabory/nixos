{ config, lib, ... }:
with lib;

let
  cfg = config.services.radicale;
in {
  config = mkIf cfg.enable {
    services.restic.backups.radicale = {
      inherit (config.piergabory.backups) repository passwordFile pruneOpts;
      initialize = true;
      timerConfig = config.piergabory.backups.timerConfig // {
        OnCalendar = "03:30";
      };
      paths = [
        "/var/lib/radicale/collections"
      ];
      extraBackupArgs = [
        "--tag radicale"
        "--one-file-system"
      ];
    };
  };
}
