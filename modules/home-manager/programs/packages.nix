{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      fastfetch
      imv # image viewer for tiling managers
      mpv # video player
      parabolic # Youtube downloader
      transmission_4-qt # Torrent client
      beeper # Chat aggregator
      clock-rs
      unzip
      parted
      ragenix
      nautilus
      signal-desktop
      slack
      telegram-desktop
      whatsapp-electron
      authelia
      gimp-with-plugins
      darktable
    ];
  };
}
