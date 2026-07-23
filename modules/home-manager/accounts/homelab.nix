{ config, lib, ... }:
with lib;
let
  cfg = config.accounts.homelab;
in
{
  imports = [
    ./mkDavAccountSync.nix
  ];

  options.accounts.homelab = {
    enable = mkEnableOption "Sync with homelab dav.";
  };

  config = mkIf cfg.enable mkDavAccountSync {
    userName = "piergabory";
    passwordFile = config.age.secrets.radicale-dav.path;
    calurl = "https://dav.pierr.re";
    cardurl = "https://dav.pierr.re";
  };
}
