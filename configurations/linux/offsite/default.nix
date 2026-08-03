{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../linux.nix
  ];

  config = {
    networking.hostName = "offsite";
    console.keyMap = "mac-fr";
    services.kmscon.enable = true;
    systemd.services.syncthing.serviceConfig = {
      StateDirectory = "syncthing";
      StateDirectoryMode = "0700";
    };

    # Small SSD
    boot.loader.systemd-boot.configurationLimit = 10;

    modules.offsiteBackup = {
      enable = true;

      # Resolves to the LAN address while this machine is still at home, and
      # to the public address once it has moved. Same value either way.
      source = {
        host = "pierr.re";
        hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM";
      };

      dataDisk.device = "/dev/disk/by-uuid/e1059cfd-c775-472d-aa75-b475011fb8df";

      schedule.onCalendar = "Mon,Wed,Fri 04:00";
    };

    systemd.services.offsite-disk-standby = {
      description = "Configure standby timeout for the offsite backup disk";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "offsite-disk-standby" ''
          set -eu
          ${pkgs.hdparm}/bin/hdparm -S 180 \
            /dev/disk/by-uuid/e1059cfd-c775-472d-aa75-b475011fb8df
        '';
      };
    };
  };
}
