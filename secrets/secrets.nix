let
  piergabory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQTeV5Wx7S0uHn3cn050h6xVRpXP867Mk2DoAK5qvd4";
in
{
  "samba-piergabory-homeserver.age".publicKeys = [ piergabory ];
}
