{ pkgs, ... }:

{
  programs.niri.settings.spawn-at-startup = [
      { argv = [ "waybar" ]; }
  ];

  home.packages = with pkgs; [
    swaybg
  ];
}
