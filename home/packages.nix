{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    fastfetch
    _1password-gui

    zed-editor
    nil
    nixd

    webcord
    bazaar
    gitui
    opencode
    home-manager
    kdePackages.elisa
  ];
}
