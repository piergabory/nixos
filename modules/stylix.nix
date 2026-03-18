{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    icons = {
      enable = true;
      light = "MoreWaita";
      dark = "MoreWaita";
      package = pkgs.morewaita-icon-theme;
    };

    fonts = {
      sizes = {
        applications = 10;
        desktop = 10;
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
}
