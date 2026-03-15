{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = with pkgs; [
      rofi-calc
      rofi-top
      rofi-emoji
      rofi-rbw
      rofi-file-browser
      rofi-mpd
      rofi-power-menu
    ];
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      show-icons = true;
      modi = "drun,ssh,window,calc,emoji,top";
    };
  };

  home.packages = with pkgs; [
    rbw
  ];
}
