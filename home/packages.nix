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
    jellyfin-tui # Jellyfin terminal client
    superfile # TUI file managers
    whatsapp-electron # whatsapp client
    castero # Podcast player
    transmission_4-gtk # Torrent client
    rustmission

    baobab # Disk usage utility like grand perspective
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

    sirula # app launcher

    github-copilot-cli # github copilot
    bitwarden-cli
    bitwarden-desktop
    rbw # Better bitwarden client that holds key in memory

    beeper # Chat aggregator

    calcurse # Calendar TUI
    abook # Address book

    # Photography:
    xsane # Very old scanner software
    exiftool # Metadata editor
    gimp
    shotwell
    digikam
    gthumb
    photoqt
    rawtherapee
    geeqie

    # Office
    libreoffice
  ];
}
