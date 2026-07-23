{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    networking = {
      hostName = "pierre-offsite-backup";
    };

    services.openssh.enable = true;
  };
}
