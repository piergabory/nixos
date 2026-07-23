{ config, lib, ... }:
with lib;

let
  cfg = config.services.authentication;
in {
  imports = [
    ./authelia.nix
    ./backup.nix
  ];

  options.services.authentication = {
    enable = mkEnableOption "Authentication service";
    domain = mkOption {
      type = types.str;
    };
    host = mkOption {
      type = types.str;
      default = "auth.${cfg.domain}";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${cfg.host}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9092";
        proxyWebsockets = true;
      };
    };
  };
}
