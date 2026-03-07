{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    fastfetch
    _1password-gui
    zed-editor
    webcord
    bazaar
    gitui
    opencode
    home-manager
  ];
}
