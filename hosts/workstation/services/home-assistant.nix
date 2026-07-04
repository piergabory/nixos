{
  ageSecrets,
  config,
  ...
}:

{
  age.secrets.home-assistant-token = ageSecrets.home-assistant-token;

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

  networking.firewall.allowedTCPPorts = [
    21064 # Homekit bridge
    21065 # Homekit TV bridge
    21066 # Homekit TV bridge
    21067 # HomeKit Lights
  ];

  hardware.bluetooth.enable = true;

  services.nginx.virtualHosts."hass.pierr.re" = {
    serverAliases = [ "home.piergabory.net" ];
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
