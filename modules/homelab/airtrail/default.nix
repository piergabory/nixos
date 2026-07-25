{ config, lib, ... }:
with lib;

let
  cfg = config.services.airtrail;
in {
  imports = [
    ./secrets
    ./backup.nix
    ./airtrail.nix
  ];

  config = mkIf cfg.enable {
    services.airtrail = {
      environmentFile = config.age.secrets.airtrail-env.path;
      port = 3001;
    };

    # The domain name must be consistent with the environment declared in the ragenix secret.
    services.nginx.virtualHosts."flights.pierr.re" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
