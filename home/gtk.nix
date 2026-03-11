{ pkgs, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    bibata-cursors
    gnome-themes-extra
    inter
    inter-nerdfont
  ];

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk;
    };

    iconTheme = {
      name = "Morewaita-Dark";
      package = pkgs.morewaita-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = "Inter";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
