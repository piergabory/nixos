{ config, ... }:

{
  age.secrets.home-assistant-token = {
    file = ../secrets/home-assistant-token.age;
    mode = "0644";
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "isal"
      "matter"
      "netatmo"
      "homekit"
      "homekit_controller"
      "overkiz"
      "xiaomi_miio"
      "androidtv_remote"
      "zha"
    ];
    config = {
      default_config = {
      };
      http = {
        server_host = "127.0.0.1";
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      homeassistant = {
        internal_url = "http://192.168.1.4:8123";
        external_url = "https://home.piergabory.net";
      };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include automations.yaml";
      "script ui" = "!include automations.yaml";
    };
  };

  services.home-assistant-matter-hub = {
    enable = true;
    accessTokenFile = config.age.secrets.home-assistant-token.path;
    openFirewall = true;
    settings = {
      homeAssistantUrl = "https://home.piergabory.net";
      httpPort = 8482;
    };
  };

  services.matter-server = {
    enable = true;
    openFirewall = true;
  };

  # services.openthread-border-router = {
  #   enable = true;
  #   openFirewall = true;
  #   radio.device = "/dev/something";
  # };

  networking.firewall.allowedTCPPorts = [
    8123
  ];

  hardware.bluetooth.enable = true;

  services.nginx.virtualHosts."home.piergabory.net" = {
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
}
