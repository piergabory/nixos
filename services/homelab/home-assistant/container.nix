{ config, lib, ... }:
with lib;

let
  cfg = config.services.hass-container;
in {
  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      oci-containers = {
        backend = "podman";
        containers.homeassistant = {
          image = "ghcr.io/home-assistant/home-assistant:stable";
          environment.TZ = "Europe/Paris";
          autoStart = true;
          privileged = true;
          extraOptions = [
            "--network=host"
          ];
          volumes = [
            "/var/lib/homeassistant:/config"
            "/run/dbus:/run/dbus:ro"
          ];
        };
      };
    };
  };
}
