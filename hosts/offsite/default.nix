{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../configuration.nix
  ];

  config = {
    networking = {
      hostName = "pierre-offsite-backup";
    };

    services = {
      openssh.enable = true;
      syncthing.enable = true;
    };

    home-manager.managed-users = [ "piergabory" "root" ];
  };
}
