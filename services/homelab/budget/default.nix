{ config, lib, ... }:
with lib;

let
  cfg = config.services.actual;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.actual = {
      settings = {
        port = 3000;
        hostname = "127.0.0.1";
      };
    };

    services.nginx.virtualHosts = {
      "budget.pierr.re" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
      };
    };
  };
}
