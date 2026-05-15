{ pkgs, ... }:

{
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      epkowa
      epsonscan2
    ];
  };

  services.udev.packages = with pkgs; [
    epkowa
    epsonscan2
  ];
}
