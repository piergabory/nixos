{ ... }:

{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR mail@piergabory.net
    '';
  };

  fileSystems."/storage" = {
    device = "/dev/disk/by-uuid/5f3732cd-17aa-41d7-93ae-64453ead7510";
    fsType = "ext4";
    options = [
      "nofail" # don't drop to emergency mode if the RAID array is absent
      "x-systemd.device-timeout=120" # give the RAID time to assemble before giving up
    ];
  };
}
