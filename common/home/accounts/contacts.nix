{ config, lib, osConfig, ... }:

{
  config = lib.mkIf (config.home.username == "piergabory") {
    accounts.contact.accounts = {
      radicale = {
        remote = {
          type = "carddav";
          url = "https://dav.piergabory.net/radicale/";
          userName = "piergabory";
          passwordCommand = [ "cat" osConfig.age.secrets.radicale-dav.path ];
        };
        vdirsyncer = {
          enable = true;
          collections = [ "from a" ];
          conflictResolution = "remote wins";
          metadata = [ "displayname" ];
        };
        khard = {
          enable = true;
          type = "discover";
        };
      };

      icloud = {
        remote = {
          type = "carddav";
          url = "https://contacts.icloud.com/";
          userName = "piergabory@icloud.com";
          passwordCommand = [ "cat" osConfig.age.secrets.icloud-dav.path ];
        };
        vdirsyncer = {
          enable = true;
          collections = [ "from a" ];
          conflictResolution = "remote wins";
          metadata = [ "displayname" ];
        };
        khard = {
          enable = true;
          type = "discover";
        };
      };
    };
  };
}
