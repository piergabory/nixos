{ config, lib, ... }:
with lib;

let
  cfg = config.services.homelab;
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

  options.services.homelab = {
    enable = mkEnableOption "Deploy the home-lab stack on this machine";
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
        domain = "pierr.re";
      };

      hass-container = {
        enable = true;
        domain = "hass.pierr.re";
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
