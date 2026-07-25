{ config, lib, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.nginx;
in {
  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "home_lab@${domain}";
    };

    services.nginx = {
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."${domain}" = {
        root = "/var/http/html";
        default = true;
        serverAliases = [
          "www.${domain}"
          "piergabory.net"
          "www.piergabory.net"
        ];
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          tryFiles = "$uri $uri/ $uri.html =404";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.tmpfiles.rules = [
      "d /var/http/html 0755 piergabory nginx -"
    ];
  };
}
