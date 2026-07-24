{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets = {
    radicale-admin = {
      file = ./radicale/admin.age;
      owner = "radicale";
    };
    radicale-dav = {
      file = ./radicale/dav.age;
      owner = "piergabory";
    };
    icloud-smtp-relay.file = ./icloud/smtp-relay.age;

    syncthing-api = {
      file = ./syncthing/api.age;
      owner = "piergabory";
    };
    syncthing-gui = {
      file = ./syncthing/admin.age;
      owner = "piergabory";
    };

    home-assistant-token.file = ./home-assistant-token.age;
    restic-password.file = ./restic-password.age;
    airtrail-env.file = ./airtrail-env.age;
    immich-api.file = ./immich.age;
    jellyfin-api.file = ./jellyfin.age;
  }
  // (
    let
      s = file: {
        inherit file;
        owner = "authelia-main";
      };
    in
    {
      authelia-oidc-clients = s ./authelia/oidc/clients.age;
      authelia-oidc-hmac = s ./authelia/oidc/hmac.age;
      authelia-oidc-jwks = s ./authelia/oidc/jwks.age;
      authelia-jwt = s ./authelia/jwt.age;
      authelia-session = s ./authelia/session.age;
      authelia-storage-key = s ./authelia/storage-key.age;
      authelia-users = s ./authelia/users.age;
    }
  );
}
