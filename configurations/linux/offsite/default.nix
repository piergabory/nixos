{
  imports = [
    ./hardware.nix
    ../linux.nix
  ];

  config = {
    networking.hostName = "offsite";
    console.keyMap = "mac-fr";
    services.kmscon.enable = true;
  };
}
