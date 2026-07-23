{ config, lib, ... }:
with lib;

let
  cfg = config.services.hass-container;
in {
  config = mkIf cfg.enable {
    services.home-assistant-matter-hub = {
      enable = true;
      accessTokenFile = config.age.secrets.home-assistant-token.path;
      openFirewall = true;
      settings = {
        homeAssistantUrl = "https://${cfg.domain}";
        httpPort = 8482;
      };
    };

    services.matter-server = {
      enable = true;
      openFirewall = true;
    };
  };
}
