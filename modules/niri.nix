{ pkgs, ... }:

{
  programs.niri.enable = true;
  programs.waybar.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    nautilus
    fuzzel
    mako
    xwayland-satellite
    dconf
    gsettings-desktop-schemas
  ];
}
