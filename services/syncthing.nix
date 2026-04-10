{ config, ... }:

{
  age.secrets.syncthing = {
    file = ../secrets/syncthing-gui.age;
    mode = "0644";
  };
  
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "piergabory"; # User for disk permissions
    guiPasswordFile = config.age.secrets.syncthing.path;
    settings = {
      gui.user = "piergabory";
      folders = {
        "Desktop" = {
          path = "/home/piergabory/Desktop";
          devices = [ "home-server" "workstation" ];
        };
        "Documents" = {
          path = "/home/piergabory/Documents";
          devices = [ "home-server" "workstation" ];
        };
        "Music" = {
          path = "/home/piergabory/Music";
          devices = [ "home-server" "workstation" ];
          type = "receiveonly";
        };
      };
      devices = {
        "home-server".id = "XDBFUR4-FFBPR4G-JVVWYXJ-W2CFGNR-HF66NN7-U75MNVQ-U2WRMEP-R73RPQD";
        "workstation".id = "JUSBZZQ-6LIX2EW-EIYJSGL-XU55D26-ZAHSVEN-BP7JVWX-DP4DTZI-QQP3WQI";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
