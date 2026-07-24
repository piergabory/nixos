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

  config = mkIf cfg.enable (mkDavAccountSync {
    label = "homelab";
    userName = "piergabory";
    passwordFile = config.age.secrets.radicale-dav.path;
    calurl = "https://dav.pierr.re";
    cardurl = "https://dav.pierr.re";
  });
}
