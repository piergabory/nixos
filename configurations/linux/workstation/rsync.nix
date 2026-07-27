{ config, ... }:

let
  homeDir = config.mainUser.homeDirectory;
  syncConfig = {
    settings = {
      archive = true;
      delete = true;
      human-readable = true;
      mkpath = true;
    };

    user = config.mainUser.username;
    group = "users";

    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };
in {
  services.rsync = {
    enable = true;

    jobs.documents = {
      sources = [ "${homeDir}/Documents/" ];
      destination = "/storage/documents/";
    } // syncConfig;

    jobs.notes = {
      sources = [ "${homeDir}/Notes/" ];
      destination = "/storage/backups/notes";
    } // syncConfig;

    jobs.music = {
      sources = [ "${homeDir}/Music/" ];
      destination = "/storage/jellyfin/music";
    } // syncConfig;
  };
}
