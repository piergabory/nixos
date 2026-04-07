{ pkgs, lib, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop-rocm;
    settings = {
      color_theme = lib.mkForce "ayu";
      theme_background = lib.mkForce false;  
    };
  };
}
