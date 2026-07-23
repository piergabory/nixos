let
  syncConfig = {
    settings = {
      archive = true;
      delete = true;
      human-readable = true;
      mkpath = true;
    };

    user = "piergabory";
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
      sources = [ "/home/piergabory/Documents/" ];
      destination = "/storage/documents/";
    } // syncConfig;

    jobs.notes = {
      sources = [ "/home/piergabory/Notes/" ];
      destination = "/storage/backups/notes";
    } // syncConfig;

    jobs.music = {
      sources = [ "/home/piergabory/Music/" ];
      destination = "/storage/jellyfin/music";
    } // syncConfig;
  };
}
