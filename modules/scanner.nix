{ config, pkgs, lib, ... }:
with lib;

let
  scannerBackends = with pkgs; [ epkowa epsonscan2 ];
  cfg = config.modules.filmScanning;
in {
  options.modules.filmScanning = {
    enable = mkEnableOption "Support scanner device";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.skanlite
    ];

    hardware.sane = {
      enable = true;
      extraBackends = scannerBackends;
    };

    services.udev.packages = scannerBackends;
  };
}
