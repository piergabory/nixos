{ ... }:

{
  # programs.light = {
  #   enable = true;
  #   brightnessKeys = {
  #     enable = true;
  #     minBrightness = 0;
  #     step = 10;
  #   };
  # };

  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 374 ];
        events = [ "key" ];
        # Todo script looping because i think this doens't allow lowering the value
        # BTW the minimum is 50
        command = ''
          /run/wrappers/bin/light -A 10 -s sysfs/leds/tpacpi::kbd_backlight
        '';
      }
      # { keys = [ ??? ]; events = [ "key" ]; command = "/run/wrappers/bin/light -U 10"; }
    ];
  };
}
