{ ... }:

{
  programs.niri.settings.input = {
    keyboard = {
      xkb = {
        layout = "fr";
        variant = "mac";
      };
      numlock = true;
    };

    mouse = {
      natural-scroll = true;
      accel-speed = 0.2;
    };
  };
}
