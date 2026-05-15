{ config, ... }:

{
  age.secrets = {
    dash = {
      file = ../../../../secrets/dash.age;
      group = config.services.nginx.group;
      mode = "0440";
    };
    immich-api.file = ../../../../secrets/immich.age;
    jellyfin-api.file = ../../../../secrets/jellyfin.age;
    syncthing-api.file = ../../../../secrets/syncthing.age;
  };
}
