let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMga0Y7kXjR5Dk3KrcbmuuXFPu7OTZu0LlxcwQKmibyn root@nixos";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM root@workstation";
  keys = [ root system ];
in {
  "syncthing/workstation.age".publicKeys = keys;
  "syncthing/api.age".publicKeys = keys;
}
