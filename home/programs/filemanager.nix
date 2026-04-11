{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thunar
  ];
  
  programs.niri.settings.binds = {
    "Mod+Shift+T".action.spawn = [ "thunar" ];
  };
}
