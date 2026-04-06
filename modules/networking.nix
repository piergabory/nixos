{ ... }:

{
  networking = {
    hostName = "thinkpad";
    networkmanager.enable = true;
    hosts = {
      "192.168.1.4" = [ "homeserver" "home-server" ];
    };
  };
}
