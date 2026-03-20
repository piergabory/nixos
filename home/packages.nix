{ pkgs, ... }:

{
  home.packages = with pkgs; [
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


    # instagram-cli Not available
    # endcord Not available
    # discordo Not available
    nchat # whatsapp and telegram
    toot # Mastodon
    meli # email

    youtube-tui # Youtube music player
    youtube-viewer # Youtube wrapper
    mpv # video player

    github-copilot-cli # github copilot
    bitwarden-cli
    bitwarden-desktop
    rbw # Better bitwarden client that holds key in memory

    beeper # Chat aggregator

    calcurse # Calendar TUI
    gnome-calendar
    abook # Address book
    gnome-contacts
  ];
}
