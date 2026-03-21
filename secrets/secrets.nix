let
  piergabory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQTeV5Wx7S0uHn3cn050h6xVRpXP867Mk2DoAK5qvd4";
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQ0bRf4yX3NHkM3hyccW2m+GBhPIUjOfkhKgZBeKkBv";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAywPQ+IzZFizfeXYuz9PklOK1Wg9jGXkVSEjEYqZQ0B";
in
{
  "samba-homeserver.age".publicKeys = [ piergabory root system ];
}
