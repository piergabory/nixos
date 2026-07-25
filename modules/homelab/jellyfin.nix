{ config, lib, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.jellyfin;
in {
  config = mkIf cfg.enable {
    services.jellyfin = {
      user = "piergabory"; # TODO FIXME use default jellyfin user
      group = "users";

      dataDir = "/storage/jellyfin";
      configDir = "/srv/jellyfin";
      logDir = "/srv/jellyfin/logs";
      cacheDir = "/tmp/jellyfin";
    };

    # TODO: Is this necessary?
    # Force Jellyfin to use integrated GPU (GPU 1) instead of discrete GPU (GPU 0)
    # HIP_VISIBLE_DEVICES accepts device index (0, 1, 2, etc) or "all"
    systemd.services.jellyfin.environment = {
      HIP_VISIBLE_DEVICES = "1";
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
