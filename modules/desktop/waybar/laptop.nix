{ config, lib, ... }:
with lib;

let
  cfg = config.programs.waybar;
in {
  options.programs.waybar = {
    enableStatusWidgets = mkEnableOption "Show widgets for laptops";
    showBattery = mkEnableOption "Show battery";
  };

  config = mkIf cfg.enableStatusWidgets {
    programs.waybar.settings.primary = {
      modules-right = [
        "network"
        "bluetooth"
        "pulseaudio"
        "backlight"
        (mkIf cfg.showBattery "battery")
      ];

      battery = mkIf cfg.showBattery {
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
      "bluetooth" = {
        format = " {status}";
      };
    };
  };
}
