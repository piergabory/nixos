{ lib, ... }:

{
  services.jellyfin = lib.mkForce {
    enable = true;
    user = "piergabory";
    group = "users";

    dataDir = "/storage/jellyfin";
    configDir = "/srv/jellyfin";
    logDir = "/srv/jellyfin/logs";
    cacheDir = "/tmp/jellyfin";
  };

  # Force Jellyfin to use integrated GPU (GPU 1) instead of discrete GPU (GPU 0)
  # HIP_VISIBLE_DEVICES accepts device index (0, 1, 2, etc) or "all"
  systemd.services.jellyfin.environment = {
    HIP_VISIBLE_DEVICES = "1";
  };

  services.nginx.virtualHosts."jelly.pierr.re" = {
    serverAliases = [ "jelly.piergabory.net" ];
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };
  };
}
