{ lib, pkgs, ... }:
with lib;
{
  imports = [
    ./beets.nix
    ./browser.nix
    ./packages.nix
  ];

  config = {
    programs = {
      obsidian.enable = true;
      btop.enable = true;
      rmpc.enable = true;
      zapzap.enable = true;

      thunderbird = {
        enable = true;
        languagePacks = [
          "en-US"
          "en-UK"
          "fr"
        ];
      };

      foot = mkIf pkgs.stdenv.isLinux {
        enable = true;
        server.enable = true;
        settings.main.pad = "8x8";
      };

      vicinae = mkIf pkgs.stdenv.isLinux {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
