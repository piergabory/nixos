{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xfce.thunar
  ];
  
  programs.niri.settings.binds = {
    "Mod+M".action.spawn = [ "thunar" ];
  };
}
