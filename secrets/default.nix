let
  secret = file: owner: {
    inherit file owner;
    mode = "0400";
  };

  rootSecret = file: secret file "root";
in
{
  dash = secret ./dash.age "nginx";

  home-assistant-token = rootSecret ./home-assistant-token.age;

  radicale = secret ./radicale.age "radicale";

  icloud-smtp-relay = rootSecret ./icloud-smtp-relay.age;

  restic-password = rootSecret ./restic-password.age;

  airtrail-env = rootSecret ./airtrail-env.age;

  samba-homeserver = rootSecret ./samba-homeserver.age;

  immich-api.file = ./immich.age;

  jellyfin-api.file = ./jellyfin.age;

  syncthing-api.file = ./syncthing-api.age;

  syncthing-workstation = secret ./syncthing-workstation.age "piergabory";

  syncthing-thinkpad = secret ./syncthing-thinkpad.age "piergabory";

  pixelfed-api = secret ./pixelfed-api.age "pixelfed";

  rutracker = secret ./rutracker.age;

  icloud-mail = secret ./icloud-mail.age "piergabory";

  icloud-dav = secret ./icloud-dav.age "piergabory";

  radicale-dav = secret ./radicale-dav.age "piergabory";

  mastodon-oidc-env = secret ./mastodon-oidc-env.age "mastodon";

  actual-oidc-env = secret ./actual-oidc-env.age "actual";

  authelia-jwt = secret ./authelia-jwt.age "authelia-main";

  authelia-session = secret ./authelia-session.age "authelia-main";

  authelia-storage-key = secret ./authelia-storage-key.age "authelia-main";

  authelia-oidc-hmac = secret ./authelia-oidc-hmac.age "authelia-main";

  authelia-oidc-jwks = secret ./authelia-oidc-jwks.age "authelia-main";

  authelia-users = secret ./authelia-users.age "authelia-main";

  authelia-oidc-clients = secret ./authelia-oidc-clients.age "authelia-main";
}
