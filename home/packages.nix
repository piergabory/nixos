{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop-rocm
    fastfetch
    _1password-gui


    zed-editor
    nil
    nixd

    webcord
    bazaar
    gitui
    aichat
    llm
    home-manager

    themix-gui
    swaybg

    cava # Music visualiser
    ueberzug # Graphics in terminal for alacritty
    rmpc # Rusty Music Player Client
  ];
}
