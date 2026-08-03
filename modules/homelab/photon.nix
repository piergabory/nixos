{ config, lib, ... }:
with lib;

let
  cfg = config.services.photon;
  domain = config.modules.homelab.domain;
in
{
  options.services.photon = {
    enable = mkEnableOption "Photon geocoder";
    port = mkOption {
      type = types.port;
      default = 2322;
      description = "Local port used by the Photon geocoder.";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      oci-containers = {
        backend = "podman";
        containers.photon = {
          image = "ghcr.io/rtuszik/photon-docker:2.3.1";
          autoStart = true;
          environment = {
            REGION = "planet";
            UPDATE_STRATEGY = "SEQUENTIAL";
            UPDATE_INTERVAL = "720h";
            JAVA_PARAMS = "-Xmx8g";
          };
          ports = [ "127.0.0.1:${toString cfg.port}:2322" ];
          volumes = [ "/var/lib/photon:/photon/data" ];
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/photon 0750 9011 9011 -"
    ];

    # Photon exposes an unauthenticated search and reverse-geocoding API, so
    # browser access is protected while local services use the port directly.
    services.nginx.virtualHosts."geocoder.${domain}" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = config.modules.oauth.internalAuthLocation;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = config.modules.oauth.forwardAuthConfig;
      };
    };
  };
}
