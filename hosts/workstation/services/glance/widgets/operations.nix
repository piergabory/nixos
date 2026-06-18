{ config, lib }:

let
  inherit (lib) customApi;

  immichStats = customApi {
    title = "Immich Stats";
    title-url = "https://immich.piergabory.net";
    cache = "1d";
    url = "http://127.0.0.1:${toString config.services.immich.port}/api/server/statistics";
    headers = {
      x-api-key._secret = config.age.secrets.immich-api.path;
      Accept = "application/json";
    };
    template = builtins.readFile ../templates/immich-stats.html;
  };

  piholeStats = customApi {
    title = "Pi-hole Stats";
    title-url = "https://pihole.piergabory.net";
    cache = "1m";
    url = "http://127.0.0.1:8080/api/stats/summary";
    template = builtins.readFile ../templates/pihole-stats.html;
  };

  backups = customApi {
    title = "Backups";
    cache = "1m";
    url = "http://127.0.0.1:5678/assets/backup-timers.json";
    template = builtins.readFile ../templates/backup-timers.html;
  };
in

{
  top = [
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
  ];

  inherit immichStats piholeStats backups;

  systemdServices = customApi {
    title = "Systemd services";
    cache = "1m";
    url = "http://127.0.0.1:5678/assets/systemd-services.json";
    template = builtins.readFile ../templates/systemd-services.html;
  };
}
