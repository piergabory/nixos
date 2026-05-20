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

  restic-password = rootSecret ./restic-password.age;

  samba-homeserver = rootSecret ./samba-homeserver.age;

  immich-api.file = ./immich.age;

  jellyfin-api.file = ./jellyfin.age;

  syncthing-api.file = ./syncthing-api.age;

  syncthing-workstation = secret ./syncthing-workstation.age "piergabory";

  syncthing-thinkpad = secret ./syncthing-thinkpad.age "piergabory";

  pixelfed-api = secret ./pixelfed-api.age "pixelfed";

  rutracker = secret ./rutracker.age;
}
