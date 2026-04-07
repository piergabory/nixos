{ ... }:

{
  programs.waybar.settings.primary = {
    height = 20;

    modules-left = [ "niri/window" ];
    modules-center = [ "clock" ];
    modules-right = [
      "network"
      "battery"
    ];

    "niri/workspaces".format = "{index}";
    "niri/window" = {
      format = "{title}";
      separate-outputs = true;
    };
  };
}
