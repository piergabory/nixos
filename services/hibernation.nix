# See Wiki:
# https://nixos.wiki/wiki/Hibernation

{ ... }:

{
  boot = {
    kernelParams = [
      # Read first physical offset from
      # sudo filefrag -v /var/lib/swapfile | head
      "resume_offset=946175"
      "mem_sleep_default=sleep"
    ];

    # Root partition
    resumeDevice = "/dev/disk/by-uuid/acedc05c-81bd-4f01-a158-ebe4522b5924";
  };

  powerManagement.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB
    }
  ];

  services = {
    power-profiles-daemon.enable = true;
    logind.settings.Login = {
      PowerKey = "hibernate";
      PowerKeyLongPress = "poweroff";
    };
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
