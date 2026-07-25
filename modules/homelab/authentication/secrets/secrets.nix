let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMga0Y7kXjR5Dk3KrcbmuuXFPu7OTZu0LlxcwQKmibyn root@nixos";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM root@workstation";
  keys = [ root system ];
in
{
  "age/jwt.age".publicKeys = keys;
  "age/session.age".publicKeys = keys;
  "age/storage-key.age".publicKeys = keys;
  "age/users.age".publicKeys = keys;
  "age/oidc/hmac.age".publicKeys = keys;
  "age/oidc/jwks.age".publicKeys = keys;
  "age/oidc/clients.age".publicKeys = keys;
}
