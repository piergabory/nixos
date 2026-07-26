{ config, ... }:

{
  imports = [
    ../linux.nix
    ./graphics-card.nix
    ./hardware-configuration.nix
    ./niri.nix
    ./rsync.nix
  ];

  config = {
    networking = {
      hostName = "workstation";
      networkmanager.dns = "none";
    };

    modules = {
      filmScanning.enable = true;
      graphicalDesktop.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
      homelab = {
        enable = true;
        domain = "pierr.re";
      };
    };

    powerManagement = {
      enable = true;
      cpuFreqGovernor = "performance";
    };



    # Pin the ethernet NIC to a stable name by MAC address,
    # immune to PCIe bus renumbering (e.g. adding/removing NVMe drives).
    systemd.network.links."10-ethernet" = {
      matchConfig.MACAddress = "34:5a:60:ea:c7:d6";
      linkConfig.Name = "eth0";
    };

    console.keyMap = "us";

    services =  {
      xserver.xkb.layout = "us";

      openssh.enable = true;
      syncthing.enable = true;
      logind.settings.Login = {
        HandlePowerKey = "ignore";
        PowerKeyIgnoreInhibited = false;
      };
    };

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      kernelParams = [
        "amdgpu.dc=1"
      ];

      kernel.sysctl."kernel.split_lock_mitigate" = 0;

      initrd = {
        kernelModules = [
          "md_mod"
          "raid1"
        ];

        systemd.services.assemble-storage-raid = {
          description = "Assemble /storage RAID array";
          wantedBy = [ "initrd.target" ];
          before = [ "initrd-parse-etc.service" ];
          after = [ "systemd-udev-trigger.service" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStartPre = "/bin/udevadm settle --timeout=10";
            ExecStart = "/sbin/mdadm --assemble --scan --run";
          };
        };
      };

      swraid = {
        enable = true;
        mdadmConf = ''
          ARRAY /dev/md/mac-pro-workstation:0 metadata=1.2 UUID=43cd6b10:25cf7256:b8ebe932:0e639d62
          MAILADDR ${config.modules.homelab.email}
        '';
      };
    };
  };
}
