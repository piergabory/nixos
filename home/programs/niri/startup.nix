{ pkgs, ... }:

{
  programs.niri.settings.spawn-at-startup = [
      { argv = [ "waybar" ]; }
      # { sh = "swaybg --image /etc/nixos/wallpaper.jpg"; }
  ];

  home.packages = with pkgs; [
    swaybg
  ];
}
