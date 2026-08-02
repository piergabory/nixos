{ config, lib, ... }:
with lib;

let
  cfg = config.services.syncthing;
in
{
  imports = [
    ./secrets
    ./nginx.nix
  ];

  config = {
    services.syncthing = {
      openDefaultPorts = true;
      user = "piergabory";
      guiAddress = "127.0.0.1:8384";
      guiPasswordFile = config.age.secrets.syncthing-gui.path;
      settings =
        let
          devices = {
            "workstation".id = "TVVBJOJ-6NN65F3-5AGEOPF-KNQ2ZCT-ILZ3SPV-OMTCEEQ-7HVTHVO-N5NLHAN";
            "thinkpad".id = "WBF7H4U-NJ6Z664-IH36QLD-W2ANRBR-VYUBBA7-SSUFAGZ-S6GVBZM-E2K3JA5";
            "macbook".id = "WIYD2PX-AJFKTJA-OBPG5SU-PFCHEXS-H6ZAQYB-UHFEFCX-SMTHIGJ-LQID3QY";
            "iPhone".id = "XBGPWGT-WFFRMBI-COTQCT6-RWEZYEY-LRMWLWK-IXMAJRV-DY5FBXK-UPSS7QN";
            "offsite".id = "LYLPVX6-MIDHAJD-PFXCLKQ-OBBVAHC-A7RZLYG-LAXBFKB-JTQUYFW-ZDD4AAH";
          };
          ignore = [
            "(?d).DS_Store"
            "(?d)._*"
            "(?d).AppleDouble"
            "(?d).AppleDB"
            "(?d).AppleDesktop"
            "(?d).LSOverride"
            "(?d).DocumentRevisions-V100"
            "(?d).fseventsd"
            "(?d).Spotlight-V100"
            "(?d).TemporaryItems"
            "(?d).Trashes"
            "(?d).VolumeIcon.icns"
            "(?d).com.apple.timemachine.donotpresent"
            "(?d)Icon\r"
            "(?d).Trash-*"
            "(?d).directory"
            "(?d).nfs*"
            ".obsidian/app.json"
            ".obsidian/appearance.json"
            ".obsidian/community-plugins.json"
            ".obsidian/core-plugins.json"
            ".obsidian/hotkeys.json"
            ".obsidian/workspace.json"
            ".obsidian/workspace-mobile.json"
            ".obsidian/plugins/*/data.json"
            ".obsidian/plugins/*/main.js"
            ".obsidian/plugins/*/manifest.json"
            ".obsidian/plugins/*/styles.css"
            ".obsidian/snippets/Stylix Config.css"
            "*.sync-conflict-*"
            "*.home-manager-backup"
          ];
        in
        {
          inherit devices;
          gui.user = cfg.user;
          folders = mkMerge (
            map
              (dir: {
                "${dir}" = {
                  path = "~/${dir}";
                  devices = attrNames devices;
                  ignorePatterns = ignore;
                };
              })
              [
                "Notes"
                "Desktop"
                "Documents"
                "Music"
              ]
          );
        };
    };
  };
}
