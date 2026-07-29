{
  imports = [
    ./hardware.nix
    ../linux.nix
  ];

  config = {
    networking.hostName = "offsite";
    console.keyMap = "mac-fr";
    services.kmscon.enable = true;

    modules.offsiteBackup = {
      enable = true;

      # Resolves to the LAN address while this machine is still at home, and
      # to the public address once it has moved. Same value either way.
      source = {
        host = "pierr.re";
        hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM";
      };

      dataDisk.device = "/dev/disk/by-uuid/e1059cfd-c775-472d-aa75-b475011fb8df";
    };
  };
}
