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
  };
}
