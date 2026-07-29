let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMga0Y7kXjR5Dk3KrcbmuuXFPu7OTZu0LlxcwQKmibyn root@nixos";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM root@workstation";

  # The offsite replica shares the repository password with the source, so
  # restic copy needs no second credential.
  offsiteRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuRnatqXTEh4liurVS8LNOI3njCSVmOHt2Qs5TVYHXT root@offsite";
  offsiteSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHf8xIos3OZiw/V7IwItIbskxTCRh2t+fD0Stc9SG5n root@nixos";

  keys = [ root system ];
  keysWithOffsite = keys ++ [ offsiteRoot offsiteSystem ];
in {
  "restic-password.age".publicKeys = keysWithOffsite;
  "icloud-smtp-relay.age".publicKeys = keys;
}
