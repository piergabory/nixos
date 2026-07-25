{ config, lib, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.vaultwarden;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.vaultwarden = {
      backupDir = "/var/backup/vaultwarden";
      environmentFile = "/var/lib/vaultwarden/vaultwarden.env";

      config = {
        DOMAIN = "https://vault.${domain}";

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        SMTP_HOST = "127.0.0.1";
        SMTP_PORT = 25;
        SMTP_SSL = false;
        SMTP_FROM = "home_lab@${domain}";
        SMTP_FROM_NAME = "pierr.re vaultwarden server";
      };
    };

    services.nginx.virtualHosts."vault.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
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
