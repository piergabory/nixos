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
      dataDir = "/var/lib/jellyfin";
      configDir = "/srv/jellyfin";
      logDir = "/srv/jellyfin/logs";
      cacheDir = "/tmp/jellyfin";

      hardwareAcceleration = {
        enable = true;
        type = "nvenc";
        device = "/dev/dri/by-path/pci-0000:01:00.0-render";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/jellyfin 0700 jellyfin jellyfin -"
    ];

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
