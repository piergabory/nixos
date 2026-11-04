{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.modules.film-photography;
  epsonscan2 = pkgs.epsonscan2.overrideAttrs (old: {
    patches = old.patches ++ [ ./patches/epsonscan2-empty-serial.patch ];
  });
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
      epsonscan2
      imv
    ];

    # Support for EPSON flatbed scanners (V800)
    hardware.sane = {
      enable = true;
      extraBackends = [ epsonscan2 ];
    };
    services.udev.packages = config.hardware.sane.extraBackends;
  };
}
