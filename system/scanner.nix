{ pkgs, ... }:

{
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      epkowa
      utsushi
    ];
  };

  services.udev.packages = with pkgs; [
    epkowa
    utsushi
  ];

  services.ipp-usb.enable = true;
}
