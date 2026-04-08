{ ... }:

{
  programs.waybar.settings.primary = {
    height = 20;

    modules-left = [ "niri/window" ];
    modules-center = [ "clock" ];
    modules-right = [
      "network"
      "pulseaudio"
      "backlight"
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
      tooltip-format-wifi = "{essid}";
      format-icons = [
        "󰤯"
        "󰤟"
        "󰤢"
        "󰤥"
        "󰤨"
      ];
    };
    "backlight" = {
      device = "intel_backlight";
      format = "{icon} {percent}%";
      format-icons = [
        "󰃞"
        "󰃟"
        "󰃠"
      ];
      states = {
        high = 90;
      };
      tooltip = false;
    };
    "pulseaudio" = {
      format = "{icon} {volume}%";
      format-muted = " {volume}%";
      format-icons = {
        headphone = "󰋋";
        default = [
          ""
          ""
          ""
        ];
      };
      states = {
        normal = 1;
        no-sound = 0;
      };
      tooltip = false;
    };
  };
}
