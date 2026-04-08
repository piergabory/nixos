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
    "battery" = {
      format = "{icon} {capacity}% ";
      format-icons = [
        ""
        ""
        ""
        ""
        ""
      ];
      states = {
        warning = 20;
        critical = 10;
        fatal = 5;
      };
    };
    "network" = {
      format = "{icon} ";
      format-icons = [
        "󰤯"
        "󰤟"
        "󰤢"
        "󰤥"
        "󰤨"
      ];
    };
  };
}
