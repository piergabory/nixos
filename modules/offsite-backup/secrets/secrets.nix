let
  offsiteRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuRnatqXTEh4liurVS8LNOI3njCSVmOHt2Qs5TVYHXT root@offsite";
  offsiteSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHf8xIos3OZiw/V7IwItIbskxTCRh2t+fD0Stc9SG5n root@nixos";

  # These secrets are only ever read by the offsite machine.
  keys = [
    offsiteRoot
    offsiteSystem
  ];
in
{
  "offsite-pull-key.age".publicKeys = keys;
  "offsite-healthcheck-url.age".publicKeys = keys;
}
