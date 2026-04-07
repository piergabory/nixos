{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    # image = ./wallpaper.jpg;

    icons = {
      enable = true;
      light = "xfce4-icon-theme";
      dark = "xfce4-icon-theme";
      package = pkgs.xfce.xfce4-icon-theme;
    };

    fonts = {
      sizes = {
        applications = 9;
        desktop = 9;
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
    xfce.xfce4-icon-theme
  ];
}
