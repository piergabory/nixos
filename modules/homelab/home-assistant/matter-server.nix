{ config, lib, ... }:
with lib;

let
  cfg = config.services.hass-container;
in {
  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

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
      # Matter devices advertise scoped IPv6 addresses on the wired LAN.
      extraArgs.primary-interface = "eth0";
    };

    # The current DCL response contains a certificate that matter-server 8.1.2
    # cannot parse. Keep the known-good certificate cache for now.
    systemd.services.matter-server.preStart = ''
      touch /var/cache/matter-server/certs/.version
    '';
  };
}
