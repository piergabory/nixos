let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3AauF9raJ3/hMUPdNPqaRbg2mTBk4efylMvSAOaG2S root@thinkpad";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVaLgeww5DZ0ZU2l92IF5CFTsau/kjEDeIwtmVhWXtb root@thinkpad";
in
{
  "samba-homeserver.age".publicKeys = [ root system ];
  "syncthing-gui.age".publicKeys = [ root system ];
}
