{ ageSecrets, config, ... }:

{
  age.secrets.syncthing = ageSecrets.syncthing-workstation;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "piergabory";
    guiAddress = "192.168.1.4:8384";
    guiPasswordFile = config.age.secrets.syncthing.path;
    settings = {
      gui.user = "piergabory";
      folders = {
        "Desktop" = {
          path = "/home/piergabory/Desktop";
          devices = [
            "thinkpad"
            "macbook"
          ];
        };
        "Documents" = {
          path = "/home/piergabory/Documents";
          devices = [
            "thinkpad"
            "macbook"
          ];
        };
        "Music" = {
          path = "/home/piergabory/Music";
          devices = [
            "thinkpad"
            "macbook"
          ];
          type = "sendonly";
        };
      };
      devices = {
        "thinkpad".id = "WBF7H4U-NJ6Z664-IH36QLD-W2ANRBR-VYUBBA7-SSUFAGZ-S6GVBZM-E2K3JA5";
        "macbook".id = "WIYD2PX-AJFKTJA-OBPG5SU-PFCHEXS-H6ZAQYB-UHFEFCX-SMTHIGJ-LQID3QY";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  services.nginx.virtualHosts."sync.piergabory.net" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://192.168.1.4:8384";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
