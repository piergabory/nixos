{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    nnn
    imv # image viewer for tiling managers
    mpv # video player
    cava # Music visualiser
    rmpc # Rusty Music Player Client
    thunderbird # Mail client
    _1password-gui # 1Password
    webcord # Discord
    parabolic # Youtube downloader
    transmission_4-qt6 # Torrent client
    rustmission
    baobab # Disk usage utility like grand perspective
    github-copilot-cli # github copilot
    rbw # Better bitwarden client that holds key in memory
    beeper # Chat aggregator
    libreoffice
    nix-index
    nix-doc
    nix-btm
    nix-top
    nix-tree
    nix-health
    nix-output-monitor
    zeal
    opencode
    clock-rs
    unzip
    parted
    ragenix
    nautilus
    ripgrep
    jq
    yq-go
    eza
    fzf
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    hugo
    glow
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
    codex
    alpine # mail client
    kdePackages.skanlite # SANE scanner frontend with preview/crop controls
    mistral-vibe # Mistral CLI
    signal-desktop
    evolution
    slack
    telegram-desktop
    whatsapp-electron
    obsidian
  ];
}
