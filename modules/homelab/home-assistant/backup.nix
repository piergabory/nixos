{ config, lib, ... }:
with lib;

let
  cfg = config.services.hass-container;
in {
  config = mkIf cfg.enable {
    services.rsync = {
      enable = true;

      jobs.homeassistant-backups = {
        sources = [ "/var/lib/homeassistant/backups/" ];
        destination = "/storage/backups/homeassistant";

        settings = {
          archive = true;
          delete = false;
          human-readable = true;
          mkpath = true;
        };

        user = "root";
        group = "root";

        timerConfig = {
          OnCalendar = "*:0/5";
          Persistent = true;
        };
      };
    };

    # The rsync job above only moves Home Assistant's own archives onto the
    # storage array. Without this they never enter the restic repository, and
    # so would never reach the offsite replica.
    services.restic.backups.home-assistant = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;

      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "04:30";
      };

      paths = [
        "/storage/backups/homeassistant"
      ];

      extraBackupArgs = [
        "--tag home-assistant"
        "--one-file-system"
      ];
    };
  };
}
