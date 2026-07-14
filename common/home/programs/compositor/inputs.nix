{ ... }:

{
  programs.niri.settings.input = {
    keyboard = {
      # xkb.layout = "fr";
      xkb.options = "compose:menu";
      numlock = true;
    };

    mouse = {
      natural-scroll = true;
      accel-speed = 0.2;
    };
  };
}
