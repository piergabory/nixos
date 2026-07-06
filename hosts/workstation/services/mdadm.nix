{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mdadm # Software RAID for /storage
  ];

  boot = {
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
        MAILADDR home_lab@pierr.re
      '';
    };
  };
}
