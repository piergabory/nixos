{ ageSecrets, config, ... }:

{
  age.secrets.syncthing = ageSecrets.syncthing-thinkpad;

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
          devices = [
            "workstation"
            "macbook"
            "iPhone"
          ];
        };
        "Documents" = {
          path = "/home/piergabory/Documents";
          devices = [
            "workstation"
            "macbook"
            "iPhone"
          ];
        };
        "Music" = {
          path = "/home/piergabory/Music";
          devices = [
            "workstation"
            "macbook"
            "iPhone"
          ];
          type = "receiveonly";
        };
      };
      devices = {
        "workstation".id = "TVVBJOJ-6NN65F3-5AGEOPF-KNQ2ZCT-ILZ3SPV-OMTCEEQ-7HVTHVO-N5NLHAN";
        "macbook".id = "WIYD2PX-AJFKTJA-OBPG5SU-PFCHEXS-H6ZAQYB-UHFEFCX-SMTHIGJ-LQID3QY";
        "iPhone".id = "XBGPWGT-WFFRMBI-COTQCT6-RWEZYEY-LRMWLWK-IXMAJRV-DY5FBXK-UPSS7QN";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
