{ lib, pkgs, ... }:
with lib;
with pkgs;
{
  config = {
    home.packages = mkIf stdenv.isLinux [
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
      gimp-with-plugins
      darktable
    ];
  };
}
