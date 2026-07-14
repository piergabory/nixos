{
  config,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf (config.home.username == "piergabory") {
    accounts.calendar.accounts = {
      radicale = {
        primary = true;
        primaryCollection = "home";
        remote = {
          type = "caldav";
          url = "https://dav.pierr.re";
          userName = "piergabory";
          passwordCommand = [
            "cat"
            osConfig.age.secrets.radicale-dav.path
          ];
        };
        vdirsyncer = {
          enable = true;
          collections = [ "from a" ];
          conflictResolution = "remote wins";
          metadata = [
            "color"
            "displayname"
          ];
        };
        khal = {
          enable = true;
          type = "discover";
        };
      };

      icloud = {
        remote = {
          type = "caldav";
          url = "https://caldav.icloud.com/";
          userName = "piergabory@icloud.com";
          passwordCommand = [
            "cat"
            osConfig.age.secrets.icloud-dav.path
          ];
        };
        vdirsyncer = {
          enable = true;
          collections = [ "from a" ];
          conflictResolution = "remote wins";
          metadata = [
            "color"
            "displayname"
          ];
        };
        khal = {
          enable = true;
          type = "discover";
        };
      };
    };
  };
}
