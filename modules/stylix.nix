{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    image = /etc/nixos/wallpaper.jpg;

    icons = {
      enable = true;
      light = "Adwaita";
      dark = "Adwaita";
      package = pkgs.morewaita-icon-theme;
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
    adwaita-icon-theme
    morewaita-icon-theme
  ];
}
