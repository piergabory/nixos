{ ... }:

{
  programs.waybar = {
    enable = true;

    settings.primary = {
      height = 24;

      modules-left = [ "niri/workspaces" "wlr/taskbar" ];
      modules-center = [ "niri/window" ];
      modules-right = [ "clock" ];

      "niri/workspaces".format = "{index}";
      "niri/window" = {
        format = "{title}";
        separate-outputs = true;
      };
      "wlr/taskbar" = {
        format = "{name}";
        tooltip = false;
      };
      "clock".format = "{:%c}"; #"{:%A %B %d %Y %H:%M}";
    };

    style = ./config/style.css;
  };
}
