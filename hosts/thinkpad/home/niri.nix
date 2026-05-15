{ lib, ... }:

{
  programs.niri.settings = {
    spawn-at-startup = lib.mkAfter [
      { argv = [ "blueman-applet" ]; }
    ];

    binds = {
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "+10%"
        ];
      };

      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "10%-"
        ];
      };
    };

    layout = {
      struts.top = lib.mkForce (-10);
      gaps = lib.mkForce 10;
    };
  };
}
