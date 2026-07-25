{ config, lib, ... }:
with lib;

let
  cfg = config.services.hass-container;
in
{
  imports = [
    ./secrets
    ./backup.nix
    ./container.nix
    ./matter-server.nix
  ];

  options.services.hass-container = {
    enable = mkEnableOption "Home assistant running in a podman container";
    domain = mkOption {
      type = types.str;
    };
    homeKitBridgesTCPPorts = mkOption {
      type = types.listOf types.int;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    networking.firewall.allowedTCPPorts = cfg.homeKitBridgesTCPPorts;

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass_header Authorization;
        '';
      };
    };
  };
}
