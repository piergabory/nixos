let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQ0bRf4yX3NHkM3hyccW2m+GBhPIUjOfkhKgZBeKkBv";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAywPQ+IzZFizfeXYuz9PklOK1Wg9jGXkVSEjEYqZQ0B";
in
{
  "samba-homeserver.age".publicKeys = [ root system ];
  "syncthing-gui.age".publicKeys = [ root system ];
}
