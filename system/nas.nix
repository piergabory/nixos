{ config, pkgs, ... }:

{
  age.secrets.samba = {
    file = /etc/nixos/secrets/samba-homeserver.age;
    mode = "0640";
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  fileSystems."/mnt/home-server/public" = {
    device = "//home-server/public";
    fsType = "cifs";
    options = [
      "guest"
      "uid=1000"
      "gid=1000"
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems."/mnt/home-server/home" = {
    device = "//home-server/home";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.samba.path}"
      "username=piergabory"
      "uid=1000"
      "gid=1000"
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems."/mnt/home-server/data" = {
    device = "//home-server/data";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.samba.path}"
      "username=piergabory"
      "uid=1000"
      "gid=1000"
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems."/mnt/home-server/storage" = {
    device = "//home-server/storage";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.samba.path}"
      "username=piergabory"
      "uid=1000"
      "gid=1000"
      "x-systemd.automount"
      "noauto"
    ];
  };
}
