{ ... }:

{
  programs.niri.settings.spawn-at-startup = [
      { argv = [ "waybar" ]; }
      { argv = [ "swaybg" "-c" "#000000" ]; }
  ];
}
