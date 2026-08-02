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
  };
in
{
  services.rsync = {
    enable = true;

    jobs.documents = syncConfig // {
      sources = [ "${homeDir}/Documents/" ];
      destination = "/storage/documents/";
      timerConfig = {
        OnCalendar = "*-*-* 01:00";
        Persistent = false;
      };
    };

    jobs.notes = syncConfig // {
      sources = [ "${homeDir}/Notes/" ];
      destination = "/storage/backups/notes";
      timerConfig = {
        OnCalendar = "*-*-* 01:05";
        Persistent = false;
      };
    };

    jobs.music = syncConfig // {
      sources = [ "${homeDir}/Music/" ];
      destination = "/storage/jellyfin/music";
      timerConfig = {
        OnCalendar = "*-*-* 01:10";
        Persistent = false;
      };
      user = config.mainUser.username;
      group = "users";
    };
  };

  systemd.tmpfiles.rules = [
    # The sync user needs to traverse Jellyfin's private top-level directory
    # and write the music subdirectory, without exposing Jellyfin's state.
    "z /storage/jellyfin 0710 jellyfin users -"
    "Z /storage/jellyfin/music 0775 jellyfin users -"
  ];
}
