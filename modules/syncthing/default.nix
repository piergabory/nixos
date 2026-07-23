{ config, lib, ... }:
with lib;

let
  cfg = config.services.syncthing;
in {
  imports= [
    ./nginx.nix
  ];

  config = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "piergabory";
      guiAddress = "127.0.0.1:8384";
      guiPasswordFile = config.age.secrets.syncthing-gui.path;
      settings = let
        devices = {
          "workstation".id = "TVVBJOJ-6NN65F3-5AGEOPF-KNQ2ZCT-ILZ3SPV-OMTCEEQ-7HVTHVO-N5NLHAN";
          "thinkpad".id = "WBF7H4U-NJ6Z664-IH36QLD-W2ANRBR-VYUBBA7-SSUFAGZ-S6GVBZM-E2K3JA5";
          "macbook".id = "WIYD2PX-AJFKTJA-OBPG5SU-PFCHEXS-H6ZAQYB-UHFEFCX-SMTHIGJ-LQID3QY";
          "iPhone".id = "XBGPWGT-WFFRMBI-COTQCT6-RWEZYEY-LRMWLWK-IXMAJRV-DY5FBXK-UPSS7QN";
        };
      in {
        inherit devices;
        gui.user = cfg.user;
        folders = mkMerge (map (dir: {
            "${dir}" = {
              path = "~/${dir}";
              devices = attrNames devices;
            };
          })
          ["Notes" "Desktop" "Documents" "Music"]
        );
      };
    };
  };
}
