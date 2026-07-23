{ config, lib, ... }:
with lib;

let
  cfg = config.modules.bluetooth;
in {
  options.modules.bluetooth = {
    enable = mkEnableOption "Bluetooth networking";
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
