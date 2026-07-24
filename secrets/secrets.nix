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
  "syncthing-thinkpad.age".publicKeys = thinkpadKeys;
  "home-assistant-token.age".publicKeys = workstationKeys;
  "restic-password.age".publicKeys = workstationKeys;
  "immich.age".publicKeys = workstationKeys;
  "jellyfin.age".publicKeys = workstationKeys;
  "airtrail-env.age".publicKeys = workstationKeys;

  "syncthing/workstation.age".publicKeys = workstationKeys;
  "syncthing/api.age".publicKeys = workstationKeys;

  "authelia/jwt.age".publicKeys = workstationKeys;
  "authelia/session.age".publicKeys = workstationKeys;
  "authelia/storage-key.age".publicKeys = workstationKeys;
  "authelia/users.age".publicKeys = workstationKeys;
  "authelia/oidc/hmac.age".publicKeys = workstationKeys;
  "authelia/oidc/jwks.age".publicKeys = workstationKeys;
  "authelia/oidc/clients.age".publicKeys = workstationKeys;
  "authelia/oidc/env/mastodon.age".publicKeys = workstationKeys;
  "authelia/oidc/env/actual.age".publicKeys = workstationKeys;

  "icloud/mail.age".publicKeys = workstationKeys ++ thinkpadKeys;
  "icloud/dav.age".publicKeys = workstationKeys ++ thinkpadKeys;
  "icloud/smtp-relay.age".publicKeys = workstationKeys;

  "radicale/admin.age".publicKeys = workstationKeys;
  "radicale/dav.age".publicKeys = workstationKeys ++ thinkpadKeys;
}
