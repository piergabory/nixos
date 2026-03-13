{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop-rocm # Supposedly system monitor with AMD support
    fastfetch
    _1password-gui # 1Password
    webcord # Discord
    imv # image viewer for tiling managers
    gnome-calculator # GUI calculator
    thunderbird # Mail client
    swaybg # desktop wallpaper
    cava # Music visualiser
    rmpc # Rusty Music Player Client
    parabolic # Youtube downloader
    beets # Music metadata fixer
    jellyfin-tui # Jellyfin terminal client
    superfile # TUI file managers
    whatsapp-electron # whatsapp client
    castero # Podcast player

    nautilus # GUI File manager
    fuzzel # Program launcher
    mako # ???
    xwayland-satellite # Xwayland support
    dconf # ???
    gsettings-desktop-schemas # ???
  ];
}
