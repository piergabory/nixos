{ config, lib, pkgs, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.radicale;
in
{
  imports = [
    ./secrets
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
        rights = {
          type = "from_file";
          file = toString (pkgs.writeText "radicale-read-only-rights" ''
            [root]
            user = .+
            collection =
            permissions = R

            [principal]
            user = .+
            collection = {user}
            permissions = R

            [collections]
            user = .+
            collection = {user}/[^/]+
            permissions = r
          '');
        };
        server.hosts = [ "127.0.0.1:5232" ];
      };
    };

    services.nginx.virtualHosts."dav.${domain}" = {
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
