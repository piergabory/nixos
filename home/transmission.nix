{ pkgs, ... }:

{
  services.transmission.enable = true;

  home.packages = with pkgs; [
    transmission_4-gtk
  ];
}
