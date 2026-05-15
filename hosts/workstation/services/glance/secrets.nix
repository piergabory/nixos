{ config, secretFiles, ... }:

{
  age.secrets = {
    dash = {
      file = secretFiles.dash;
      group = config.services.nginx.group;
      mode = "0440";
    };
    immich-api.file = secretFiles.immich;
    jellyfin-api.file = secretFiles.jellyfin;
    syncthing-api.file = secretFiles.syncthing;
  };
}
