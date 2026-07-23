{ config, lib, ... }:
with lib;
let
  cfg = config.services.syncthing;
in {
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."sync.pierr.re" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = config.piergabory.authelia.internalAuthLocation;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8384";
        proxyWebsockets = true;
        extraConfig = ''
          ${config.piergabory.authelia.forwardAuthConfig}
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
