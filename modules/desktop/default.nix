{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.modules.graphicalDesktop;
in
{
  options.modules.graphicalDesktop = {
    enable = mkEnableOption "Graphical Destop Interface";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "niri";
      gdm.enable = true;
    };

    programs = {
      niri = {
        enable = true;
      };
      xwayland.enable = true;
    };

      mainUser.homeConfiguration = {
        imports = [
          inputs.niri.homeModules.niri
          ./niri
          ./waybar
        ];
        programs = {
          niri = {
            enable = true;
            package = pkgs.niri;
            settings.input.keyboard.xkb =
            let
              xkb = config.services.xserver.xkb;
            in
            {
              layout = xkb.layout;
              variant = xkb.variant;
            };
        };
        waybar.enable = true;
      };
      services.mako.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
