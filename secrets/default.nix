{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets = {
    radicale-admin.file = ./admin.age;
    radicale-dav.file = ./dav.age;

    icloud-dav.file = ./icloud/dav.age;
    icloud-mail.file = ./icloud/mail.age;
    icloud-smtp-relay.file = ./icloud/smtp-relay.age;

    syncthing-api.file = ./syncthing/api.age;
    syncthing-gui.file = ./syncthing/workstation.age;

    home-assistant-token.file = ./home-assistant-token.age;
    restic-password.file = ./restic-password.age;
    airtrail-env.file = ./airtrail-env.age;
    samba-homeserver.file = ./samba-homeserver.age;
    immich-api.file = ./immich.age;
    jellyfin-api.file = ./jellyfin.age;
  } // (let
    s = file: { inherit file; owner = "authelia-main"; };
  in {
    authelia-oidc-clients = s ./authelia/oidc/clients.age;
    authelia-oidc-hmac = s ./authelia/oidc/hmac.age;
    authelia-oidc-jwks = s ./authelia/oidc/jwks.age;
    authelia-jwt = s ./authelia/jwt.age;
    authelia-session = s ./authelia/session.age;
    authelia-storage-key = s ./authelia/storage-key.age;
    authelia-users = s ./authelia/users.age;
  });
}
