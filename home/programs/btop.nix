{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop-rocm;
    settings = {
      color_theme = "gruvbox_dark";
      theme_background = false;  
    };
  };
}
