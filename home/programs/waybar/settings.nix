{ ... }:

{
  programs.waybar.settings.primary = {
    height = 20;

    modules-left = [ "niri/window" ];
    modules-center = [];
    modules-right = [
      "network"
      "bluetooth"
      "pulseaudio"
      "backlight"
      "battery"
      "clock"
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
      format = "{ifname}";
      format-wifi = "{icon} {essid}";
      format-ethernet = "{ipaddr}/{cidr}";
      format-disconnected = "offline";
      tooltip = false;
      format-icons = [
        "󰤯"
        "󰤟"
        "󰤢"
        "󰤥"
        "󰤨"
      ];
      max-length = 15;
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
    "clock" = {
      format = "{:%x %H:%M}";
    };
    "bluetooth" = {
      format = " {status}";
    };
  };
}
