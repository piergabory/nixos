{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
  };

  programs.waybar.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    fuzzel
    mako
    swaybg
    swayidle
    xwayland-satellite
    dconf
    gsettings-desktop-schemas

    kdePackages.dolphin
    kdePackages.discover
    kdePackages.okular
    kdePackages.gwenview
    kdePackages.breeze-icons
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    adwaita-qt

    nordzy-icon-theme
  ];
}
