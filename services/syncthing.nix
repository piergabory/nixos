{ config, ... }:

{
  age.secrets.syncthing = {
    file = /etc/nixos/secrets/syncthing-gui.age;
    mode = "0644";
  };
  
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "piergabory"; # User for disk permissions
    guiPasswordFile = config.age.secrets.syncthing.path;
    settings = {
      gui.user = "piergabory";
      folder = {
        "Documents" = {
          path = "/home/piergabory/Documents";
          devices = [ "home-server" ];
        };
      };
      devices = {
        "home-server".id = "XDBFUR4-FFBPR4G-JVVWYXJ-W2CFGNR-HF66NN7-U75MNVQ-U2WRMEP-R73RPQD";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
