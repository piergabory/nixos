{ ... }:

{
  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
    hosts = {
      "192.168.1.4" = [ "homeserver" "home-server" ];
    };
  };
}
