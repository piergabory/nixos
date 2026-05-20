{ ... }:

{
  nixarr = {
    enable = true;

    mediaDir = "/storage/media";
    stateDir = "/var/lib/nixarr";

    transmission.enable = true;
    lidarr.enable = true;
    seerr.enable = true;
    jellyfin.enable = true;

    prowlarr = {
      enable = true;
      settings-sync.enable-nixarr-apps = true;
    };

    sonarr = {
      enable = true;
      settings-sync = {
        transmission.enable = true;

        # tags = [
        #   "usenet"
        #   "torrent"
        #   "private"
        # ];

        # indexers = [
        #   {
        #     name = "RuTracker.org";
        #     sort_name = "rutracker org";
        #     fields = {
        #       baseUrl = "***REMOVED***";
        #       username = "***REMOVED***";
        #       password = "***REMOVED***";
        #     };
        #   }
        #   # {
        #   #   name = "1337x.to";
        #   #   sort_name = "1337x";
        #   #   fields.baseUrl = "***REMOVED***";
        #   # }
        # ];
      };
    };

    radarr = {
      enable = true;
      settings-sync = {
        transmission.enable = true;

        # tags = [
        #   "usenet"
        #   "torrent"
        #   "private"
        # ];

        # indexers = [
        #   {
        #     name = "RuTracker.org";
        #     sort_name = "rutracker org";
        #     fields = {
        #       baseUrl = "***REMOVED***";
        #       username = "***REMOVED***";
        #       password = "***REMOVED***";
        #     };
        #   }
        #   # {
        #   #   name = "1337x.to";
        #   #   sort_name = "1337x";
        #   #   fields.baseUrl = "***REMOVED***";
        #   # }
        # ];
      };
    };

    bazarr = {
      enable = true;

      settings-sync = {
        sonarr = {
          enable = true;
          config = {
            sync_only_monitored_series = true;
            sync_only_monitored_episodes = true;
          };
        };

        radarr = {
          enable = true;
          config.sync_only_monitored_movies = true;
        };
      };
    };
  };

  services = {
    prowlarr.settings.auth.required = "DisabledForLocalAddresses";
    lidarr.settings.auth.required = "DisabledForLocalAddresses";
    sonarr.settings.auth.required = "DisabledForLocalAddresses";
    radarr.settings.auth.required = "DisabledForLocalAddresses";
  };
}
