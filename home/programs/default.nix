{ lib, pkgs, ... }:
with lib;
{
  imports = [
    ./browser
    ./ssh.nix
    ./obsidian
  ];

  config = {
    programs = {
      zen-browser.enable = true;
      btop.enable = true;
      obsidian.enable = true;

      thunderbird = {
        enable = true;
        languagePacks = [
          "en-US"
          "en-UK"
          "fr"
        ];
      };

      foot = mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        server.enable = true;
        settings.main.pad = "8x8";
      };

      vicinae = mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        systemd.enable = true;
      };

      zapzap = mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "zapzap-wayland";
          paths = [ pkgs.zapzap ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/zapzap --set QT_QPA_PLATFORM wayland
          '';
        };
      };
    };

    home.packages =
      with pkgs;
      [
        fastfetch
        ragenix
      ]
      ++ (
        if stdenv.hostPlatform.isLinux then
          [
            imv # image viewer for tiling managers
            mpv # video player
            parabolic # Youtube downloader
            transmission_4-qt # Torrent client
            beeper # Chat aggregator
            clock-rs
            unzip
            parted
            nautilus
            signal-desktop
            slack
            telegram-desktop
            gimp-with-plugins
            darktable
          ]
        else
          [ ]
      );
  };
}
