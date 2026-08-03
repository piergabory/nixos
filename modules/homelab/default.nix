{ config, lib, ... }:
with lib;

let
  cfg = config.modules.homelab;
in
{
  imports = [
    ./airtrail
    ./authentication
    ./budget
    ./dawarich
    ./home-assistant
    ./immich
    ./jellyfin
    ./mastodon
    ./minecraft-server
    ./nginx
    ./pihole
    ./photon.nix
    ./radicale
    ./secrets
    ./vaultwarden
    ./backup.nix
    ./offsite-access
    ./postfix.nix
    ./goaccess.nix
  ];

  options.modules.homelab = {
    enable = mkEnableOption "Deploy the home-lab stack on this machine";
    domain = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
      default = "home_lab@${cfg.domain}";
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

      goaccess = {
        enable = true;
        domain = "ipstats.${cfg.domain}";
        maxmindAccountID = 1388296;
        maxmindLicenseKeyFile = config.age.secrets.maxmind-license-key.path;
        geoipDatabase = "/var/lib/GeoIP/GeoLite2-City.mmdb";
      };

      authentication = {
        enable = true;
        domain = cfg.domain;
        email = cfg.email;
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

    modules.homelab.offsiteAccess = {
      enable = true;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKd4F5DU/rs1rpNbPB3BX5OXGgIUzT+qgXf6sloq6ns1 offsite-backup-pull"
      ];
    };
  };
}
