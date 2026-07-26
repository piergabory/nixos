{ lib, pkgs, ... }:
with lib;
{
  imports = [
    ./browser.nix
    ./packages.nix
  ];

  config = {
    programs = {
      obsidian.enable = true;
      btop.enable = true;
      zapzap = {
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
