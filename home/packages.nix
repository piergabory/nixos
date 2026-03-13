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
    rmpc # Rusty Music Player Client

    parabolic # Youtube downloader
    beets # Music metadata fixer
    jellyfin-tui
    termusic

    # file managers
    yazi
    superfile

    whatsapp-electron

    castero
  ];
}
