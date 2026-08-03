{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    swraid = {
      enable = true;
      mdadmConf = ''
        ARRAY /dev/md/mac-pro-workstation:0 metadata=1.2 UUID=43cd6b10:25cf7256:b8ebe932:0e639d62
        MAILADDR ${config.modules.homelab.email}
      '';
    };

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "sd_mod"
      ];
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

    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "amdgpu" ];
    kernelParams = [ "nvidia-drm.modeset=1" ];
    kernel.sysctl."kernel.split_lock_mitigate" = 0;
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/90466ca2-de7f-4cdd-b031-b53697185f24";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3C51-AAD4";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/storage" = {
      device = "/dev/disk/by-uuid/5f3732cd-17aa-41d7-93ae-64453ead7510";
      fsType = "ext4";
    };
  };

  systemd.services.storage-disk-standby = {
    description = "Configure standby timeout for storage RAID disks";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "storage-disk-standby" ''
        set -eu
        ${pkgs.hdparm}/bin/hdparm -S 180 \
          /dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63YLKE \
          /dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63YT4F
      '';
    };
  };

  services.smartd = {
    enable = true;
    autodetect = false;
    devices = [
      {
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63YLKE";
      }
      {
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63YT4F";
      }
    ];
    notifications.mail = {
      enable = true;
      recipient = config.modules.homelab.email;
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 32768; # 32 GB
    }
  ];

  # Pin the ethernet NIC to a stable name by MAC address,
  # immune to PCIe bus renumbering (e.g. adding/removing NVMe drives).
  systemd.network.links."10-ethernet" = {
    matchConfig.MACAddress = "34:5a:60:ea:c7:d6";
    linkConfig.Name = "eth0";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
    nvidia = {
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    ''
      {
        "rules": [
          {
            "pattern": {
              "feature": "procname",
              "matches": "niri"
            },
            "profile": "Limit Free Buffer Pool On Wayland Compositors"
          }
        ],
        "profiles": [
          {
            "name": "Limit Free Buffer Pool On Wayland Compositors",
            "settings": [
              {
                "key": "GLVidHeapReuseRatio",
                "value": 0
              }
            ]
          }
        ]
      }
    '';
}
