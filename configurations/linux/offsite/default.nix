{
  imports = [
    ./hardware.nix
    ../linux.nix
  ];

  config = {
    networking.hostName = "pierre-offsite-backup";
  };
}
