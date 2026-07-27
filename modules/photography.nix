{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.modules.film-photography;
in
{
  options.modules.film-photography = {
    enable = mkEnableOption "Enable film photography environment";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gimp-with-plugins
      darktable
      kdePackages.skanlite
      imv
    ];

    # Support for EPSON flatbed scanners (V800)
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.epkowa ];
    };
    services.udev.packages = config.hardware.sane.extraBackends;
  };
}
