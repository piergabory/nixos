{ config, lib }:

let
  inherit (lib) customApi split;
  syncthingApi = config.age.secrets.syncthing-api.path;
  syncthingBaseUrl = "http://${config.services.syncthing.guiAddress}";
  syncthingFolder = folder: {
    url = "${syncthingBaseUrl}/rest/db/status";
    parameters = { inherit folder; };
    headers.X-API-Key._secret = syncthingApi;
  };
in

[
  {
    type = "server-stats";
    servers = [
      {
        type = "local";
        name = "Workstation";
      }
    ];
  }
  (import ./monitor.nix { inherit config; })
  (split [
    (customApi {
      title = "Immich Stats";
      title-url = "https://photo.piergabory.net";
      cache = "1d";
      url = "http://127.0.0.1:${toString config.services.immich.port}/api/server/statistics";
      headers = {
        x-api-key._secret = config.age.secrets.immich-api.path;
        Accept = "application/json";
      };
      template = builtins.readFile ../templates/immich-stats.html;
    })
    (customApi {
      title = "Pi-hole Stats";
      title-url = "https://pihole.piergabory.net";
      cache = "1m";
      url = "http://127.0.0.1:8080/api/stats/summary";
      template = builtins.readFile ../templates/pihole-stats.html;
    })
  ])
  (split [
    (customApi {
      title = "Syncthing Health";
      title-url = "https://sync.piergabory.net";
      cache = "1m";
      url = "${syncthingBaseUrl}/rest/system/status";
      headers.X-API-Key._secret = syncthingApi;
      subrequests = {
        desktop = syncthingFolder "Desktop";
        documents = syncthingFolder "Documents";
        music = syncthingFolder "Music";
      };
      template = builtins.readFile ../templates/syncthing-health.html;
    })
    (customApi {
      title = "Backups";
      cache = "1m";
      url = "http://127.0.0.1:5678/assets/backup-timers.json";
      template = builtins.readFile ../templates/backup-timers.html;
    })
  ])
  (customApi {
    title = "Systemd services";
    cache = "1m";
    url = "http://127.0.0.1:5678/assets/systemd-services.json";
    template = builtins.readFile ../templates/systemd-services.html;
  })
]
