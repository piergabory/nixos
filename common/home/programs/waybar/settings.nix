{ ... }:

{
  programs.waybar.settings.primary = {
    height = 24;

    modules-left = [ "niri/window" ];
    modules-center = [];
    modules-right = [
      "clock"
    ];

    "niri/workspaces".format = "{index}";
    "niri/window" = {
      format = "{title}";
      separate-outputs = true;
    };
    "clock" = {
      format = "{:%x %H:%M}";
    };
  };
}
