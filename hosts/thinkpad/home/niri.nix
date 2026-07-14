{ lib, ... }:

{
  programs.niri.settings = {
    input.keyboard.xkb.layout = "fr";

    spawn-at-startup = lib.mkAfter [
      { sh = "swaybg --image /etc/nixos/assets/house.jpg"; }
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
