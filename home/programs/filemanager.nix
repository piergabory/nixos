{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thunar
  ];
  
  programs.niri.settings.binds = {
    "Mod+M".action.spawn = [ "thunar" ];
  };
}
