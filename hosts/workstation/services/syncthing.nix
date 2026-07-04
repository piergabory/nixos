{ ageSecrets, config, ... }:

{
  age.secrets.syncthing = ageSecrets.syncthing-workstation;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "piergabory";
    guiAddress = "127.0.0.1:8384";
    guiPasswordFile = config.age.secrets.syncthing.path;
    settings = {
      gui.user = "piergabory";
      folders = {
        "Notes" = {
          path = "/home/piergabory/Notes";
          devices = [
            "thinkpad"
            "macbook"
            "iPhone"
          ];
        };
        "Desktop" = {
          path = "/home/piergabory/Desktop";
          devices = [
            "thinkpad"
            "macbook"
            "iPhone"
          ];
        };
        "Documents" = {
          path = "/home/piergabory/Documents";
          devices = [
            "thinkpad"
            "macbook"
            "iPhone"
          ];
        };
        "Music" = {
          path = "/home/piergabory/Music";
          devices = [
            "thinkpad"
            "macbook"
            "iPhone"
          ];
          type = "sendonly";
        };
      };
      devices = {
        "thinkpad".id = "WBF7H4U-NJ6Z664-IH36QLD-W2ANRBR-VYUBBA7-SSUFAGZ-S6GVBZM-E2K3JA5";
        "macbook".id = "WIYD2PX-AJFKTJA-OBPG5SU-PFCHEXS-H6ZAQYB-UHFEFCX-SMTHIGJ-LQID3QY";
        "iPhone".id = "XBGPWGT-WFFRMBI-COTQCT6-RWEZYEY-LRMWLWK-IXMAJRV-DY5FBXK-UPSS7QN";
      };
    };
  };

  services.nginx.virtualHosts."sync.pierr.re" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = config.piergabory.authelia.internalAuthLocation;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8384";
      proxyWebsockets = true;
      extraConfig = ''
        ${config.piergabory.authelia.forwardAuthConfig}
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
