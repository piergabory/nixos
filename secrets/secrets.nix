let
  thinkpadRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3AauF9raJ3/hMUPdNPqaRbg2mTBk4efylMvSAOaG2S root@thinkpad";
  thinkpadSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVaLgeww5DZ0ZU2l92IF5CFTsau/kjEDeIwtmVhWXtb root@thinkpad";
  workstationRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMga0Y7kXjR5Dk3KrcbmuuXFPu7OTZu0LlxcwQKmibyn root@nixos";
  workstationSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM root@workstation";

  thinkpadKeys = [
    thinkpadRoot
    thinkpadSystem
  ];
  workstationKeys = [
    workstationRoot
    workstationSystem
  ];
in
{
  "samba-homeserver.age".publicKeys = thinkpadKeys;
  "syncthing-thinkpad.age".publicKeys = thinkpadKeys;

  "radicale.age".publicKeys = workstationKeys;
  "home-assistant-token.age".publicKeys = workstationKeys;
  "restic-password.age".publicKeys = workstationKeys;
  "samba.age".publicKeys = workstationKeys;
  "immich.age".publicKeys = workstationKeys;
  "jellyfin.age".publicKeys = workstationKeys;
  "dash.age".publicKeys = workstationKeys;
  "syncthing-workstation.age".publicKeys = workstationKeys;
  "pixelfed-api.age".publicKeys = workstationKeys;
  "rutracker.age".publicKeys = workstationKeys;
  "syncthing-api.age".publicKeys = workstationKeys;

  "icloud-mail.age".publicKeys = workstationKeys ++ thinkpadKeys;
  "icloud-dav.age".publicKeys = workstationKeys ++ thinkpadKeys;
  "radicale-dav.age".publicKeys = workstationKeys ++ thinkpadKeys;
}
