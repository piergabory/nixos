{ config, lib, ... }:
with lib;
let
  domain = config.modules.homelab.domain;
  cfg = config.services.dawarich;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.dawarich = {
      localDomain = "geo.${domain}";
      webPort = 64645;
    };

    services.nginx.virtualHosts."geo.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.webPort}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 2048M;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
