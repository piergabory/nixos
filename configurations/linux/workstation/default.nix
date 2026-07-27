{
  imports = [
    ../linux.nix
    ./hardware.nix
    ./display-output.nix
    ./rsync.nix
  ];

  config = {
    networking = {
      hostName = "workstation";
      networkmanager.dns = "none";
    };

    mainUser.keyboardLayout = "us";

    modules = {
      film-photography.enable = true;
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

    services =  {
      openssh.enable = true;
      syncthing.enable = true;

      logind.settings.Login = {
        HandlePowerKey = "ignore";
        PowerKeyIgnoreInhibited = false;
      };
    };
  };
}
