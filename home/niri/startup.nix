{ ... }:

{
  programs.niri.settings.spawn-at-startup = [
      { argv = [ "waybar" ]; }
      { sh = "swaybg --image /home/piergabory/Pictures/wallpapers/active.jpg"; }
  ];
}
