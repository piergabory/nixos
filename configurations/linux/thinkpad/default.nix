{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
    ../linux.nix
    ./hardware-configuration.nix
  ];

  config = {
    modules = {
      graphicalDesktop.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
    };

    services = {
      logind.settings.Login = {
        HandlePowerKey = "poweroff";
        HandleLidSwitch = "hibernate";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
      };

      thermald.enable = true;
      fprintd.enable = true;
    };

    mainUser.homeConfiguration.programs = {
      waybar = {
        enableStatusWidgets = true;
        showBattery = true;
        settings.primary.height = lib.mkForce 20;
      };
      niri.settings.layout = {
        struts.top = lib.mkForce (-10);
        gaps = lib.mkForce 10;
      };
    };

    boot = {
      # should not be referring to a disk like that,
      # won't prevent boot but this is not the right way to do it.
      resumeDevice = "/dev/nvme0n1p3";

      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      kernelModules = [
        "thinkpad_acpi"
        "intel_backlight"
      ];
    };

    networking.hostName = "thinkpad";

    powerManagement.powertop.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
      powertop
    ];
  };
}
