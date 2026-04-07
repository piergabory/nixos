{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    imv # image viewer for tiling managers
    mpv # video player
    cava # Music visualiser
    rmpc # Rusty Music Player Client
    thunderbird # Mail client
    _1password-gui # 1Password
    webcord # Discord
    parabolic # Youtube downloader
    transmission_4-gtk # Torrent client
    baobab # Disk usage utility like grand perspective
    nautilus # GUI File manager
    github-copilot-cli # github copilot
    bitwarden-desktop
    rbw # Better bitwarden client that holds key in memory
    beeper # Chat aggregator
    libreoffice
    opencode
  ];
}
