{ ... }:

{
  programs.waybar = {
    enable = true;

    settings.primary = {
      height = 24;

      modules-left = [ "niri/workspaces" ];
      modules-center = [ "wlr/taskbar" ];
      modules-right = [ "clock" ];

      "niri/workspaces".format = "{index}";
      "niri/window" = {
        format = "{title}";
        separate-outputs = true;
      };
      "wlr/taskbar" = {
        format = "{title}";
        tooltip = false;
      };
      "clock".format = "{:%c}"; #"{:%A %B %d %Y %H:%M}";
    };

    style = ./config/style.css;
  };
}
