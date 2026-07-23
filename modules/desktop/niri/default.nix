{
  imports = [
    ./binds.nix
    ./layout.nix
  ];

  config = {
    programs.niri.settings = {
      debug = { };
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;
      animations.enable = false;

      spawn-at-startup = [
        { argv = [ "waybar" ]; }
        { argv = ["foot" "--server"]; }
        { argv = [ "swaybg" "-i" "/etc/nixos/wallpaper.jpeg" ]; } # TODO use path
      ];

      window-rules = [
        { draw-border-with-background = false; }
      ];

      input = {
        keyboard = {
          xkb.options = "compose:menu";
          numlock = true;
        };

        mouse = {
          natural-scroll = true;
          accel-speed = 0.2;
        };
      };
    };
  };
}
