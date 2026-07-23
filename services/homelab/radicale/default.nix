{ config, lib, ... }:
with lib;

let
  cfg = config.services.radicale;
in {
  imports  = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.radicale = {
      settings = {
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.age.secrets.radicale-admin.path;
          htpasswd_encryption = "bcrypt";
        };
        server.hosts = [ "127.0.0.1:5232" ];
      };
    };

    services.nginx.virtualHosts."dav.pierr.re" = {
      serverAliases = [ "dav.piergabory.net" ];
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5232";
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Script-Name /radicale;
          proxy_pass_header Authorization;
        '';
      };
    };
  };
}
