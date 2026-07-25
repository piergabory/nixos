{ config, lib, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.actual;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services = {
      actual = {
        settings = {
          port = 3000;
          hostname = "127.0.0.1";
        };
      };

      nginx.virtualHosts."budget.${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${cfg.settings.hostname}:${toString cfg.settings.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
