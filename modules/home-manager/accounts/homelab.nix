{ config, lib, ... }:
with lib;
let
  cfg = config.accounts.homelab;
  mkDavAccountSync = import ./mkDavAccountSync.nix;
in
{
  options.accounts.homelab = {
    enable = mkEnableOption "Sync with homelab dav.";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkDavAccountSync {
      label = "homelab";
      userName = "piergabory";
      passwordFile = config.age.secrets.radicale-dav.path;
      calurl = "https://dav.pierr.re";
      cardurl = "https://dav.pierr.re";
    })
    {
      accounts = {
        calendar.accounts.homelab-thunderbird = {
          remote = {
            type = "caldav";
            url = "https://dav.pierr.re/radicale/piergabory/CA29734E-8D86-4B4C-AEA1-EE1B0A1FB602/";
            userName = "piergabory";
          };
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
          };
        };

        contact.accounts.homelab-thunderbird = {
          remote = {
            type = "carddav";
            url = "https://dav.pierr.re/radicale/piergabory/0ac941e4-dfed-8c95-0f98-97f88d7ab88b/";
            userName = "piergabory";
          };
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
          };
        };
      };
    }
  ]);
}
