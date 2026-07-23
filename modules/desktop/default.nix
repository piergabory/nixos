{ inputs, config, lib, ... }:
with lib;

let
  cfg = config.modules.graphicalDesktop;
in {
  options.modules.graphicalDesktop = {
    enable = mkEnableOption "Graphical Destop Interface";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "niri";
      gdm.enable = true;
    };

    programs.niri.enable = true;
    programs.xwayland.enable = true;

    home-manager.users.piergabory = {
      imports = [
        inputs.niri.homeModules.niri
        ./niri
        ./waybar
      ];

      programs.waybar.enable = true;
      programs.niri.enable = true;
      services.mako.enable = true;
    };

    environment.systemPackages.packages = with pkgs; [
      swaybg
    ];
  };
}
