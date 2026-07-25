{ config, lib, ... }:
with lib;

let
  cfg = config.modules.homelab;
in {
  imports = [
    ./airtrail
    ./authentication
    ./budget
    ./dawarich
    ./home-assistant
    ./mastodon
    ./minecraft-server
    ./pihole
    ./radicale
    ./secrets
    ./vaultwarden
    ./backup.nix
    ./immich.nix
    ./jellyfin.nix
    ./nginx.nix
    ./postfix.nix
  ];

  options.modules.homelab = {
    enable = mkEnableOption "Deploy the home-lab stack on this machine";
    domain = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services = {
      actual.enable = true;
      airtrail.enable = true;
      dawarich.enable = true;
      immich.enable = true;
      jellyfin.enable = true;
      mastodon.enable = true;
      radicale.enable = true;
      pihole.enable = true;
      vaultwarden.enable = true;
      nginx.enable = true;
      postfix.enable = true;
      minecraft-server.enable = true;

      authentication = {
        enable = true;
        domain = cfg.domain;
      };

      hass-container = {
        enable = true;
        domain = "hass.${cfg.domain}";
        homeKitBridgesTCPPorts = [
          21064 # Homekit bridge
          21065 # Homekit TV bridge
          21066 # Homekit TV bridge
          21067 # HomeKit Lights
        ];
      };
    };
  };
}
