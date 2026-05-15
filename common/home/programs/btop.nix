{ pkgs, lib, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop;
    settings = {
      color_theme = lib.mkForce "gruvbox_dark_v2";
      theme_background = lib.mkForce false;  
    };
  };
}
