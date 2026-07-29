{ config, lib, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.jellyfin;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.jellyfin = {
      dataDir = "/storage/jellyfin";
      configDir = "/srv/jellyfin";
      logDir = "/srv/jellyfin/logs";
      cacheDir = "/tmp/jellyfin";

      hardwareAcceleration = {
        enable = true;
        type = "nvenc";
        device = "/dev/dri/by-path/pci-0000:01:00.0-render";
      };
    };

    services.nginx.virtualHosts."jelly.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };
  };
}
