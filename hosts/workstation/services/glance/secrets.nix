{ ageSecrets, ... }:

{
  age.secrets = {
    dash = ageSecrets.dash;
    immich-api = ageSecrets.immich-api;
    jellyfin-api = ageSecrets.jellyfin-api;
    syncthing-api = ageSecrets.syncthing-api;
  };
}
