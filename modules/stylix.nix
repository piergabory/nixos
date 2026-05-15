{ lib, pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # image = ./wallpaper.jpg;

    icons = {
      enable = true;
      light = "xfce4-icon-theme";
      dark = "xfce4-icon-theme";
      package = pkgs.xfce4-icon-theme;
    };

    fonts = {
      sizes = {
        applications = lib.mkDefault 10;
        desktop = lib.mkDefault 10;
      };

      serif = {
        package = pkgs.garamond-libre;
        name = "Garamond Libre";
      };

      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    xfce4-icon-theme
  ];
}
