{ config, lib, ... }:
with lib;

let
  lab = config.modules.homelab;
  cfg = config.services.nginx;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = lab.email;
    };

    services.nginx = {
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."${lab.domain}" = {
        root = "/var/http/html";
        default = true;
        serverAliases = [
          "www.${lab.domain}"
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

    # Keep one month of daily rotations for GoAccess.
    services.logrotate.settings.nginx = {
      frequency = "daily";
      rotate = 31;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.tmpfiles.rules = [
      "d /var/http/html 0755 piergabory nginx -"
    ];
  };
}
