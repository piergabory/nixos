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
    ./hardware-configuration.nix
    ../../modules
    ../../configuration.nix
  ];

  config = {
    modules = {
      filmScanning.enable = true;
      graphicalDesktop.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
    };

    home-manager.managed-users = [ "piergabory" "root" ];

    home-manager.users."piergabory" = {
      programs = {
        waybar = {
          enableStatusWidgets = true;
          showBattery = true;
          settings.primary.height = lib.mkForce 20;
        };
        niri.settings = {
          input.keyboard.xkb.layout = "fr";

          spawn-at-startup = lib.mkAfter [
            { sh = "swaybg --image /etc/nixos/assets/house.jpg"; }
            { argv = [ "blueman-applet" ]; }
          ];

          layout = {
            struts.top = lib.mkForce (-10);
            gaps = lib.mkForce 10;
          };
        };
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

    networking = {
      hostName = "thinkpad";
      hosts = {
        "192.168.1.4" = [
          "homeserver"
          "home-server"
        ];
      };
    };

    console.keyMap = "fr";

    services = {
      tlp = {
        # enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 20;

          # Optional helps save long term battery health
          # START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
          # STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
        };
      };

      logind.settings.Login = {
        HandlePowerKey = "poweroff";
        HandleLidSwitch = "hibernate";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
      };

      thermald.enable = true;
      fprintd.enable = true;
      xserver.xkb.layout = "fr";
      openssh.enable = true;
    };

    powerManagement.powertop.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
      powertop
    ];
  };
}
