let
  secret = file: {
    inherit file;
    mode = "0644";
  };
in
{
  dash = {
    file = ./dash.age;
    mode = "0440";
  };
  home-assistant-token = secret ./home-assistant-token.age;
  immich-api.file = ./immich.age;
  jellyfin-api.file = ./jellyfin.age;
  radicale = secret ./radicale.age;
  restic-password = {
    file = ./restic-password.age;
    mode = "0600";
  };
  samba-homeserver = secret ./samba-homeserver.age;
  syncthing = secret ./syncthing-gui.age;
  syncthing-api.file = ./syncthing.age;
}
