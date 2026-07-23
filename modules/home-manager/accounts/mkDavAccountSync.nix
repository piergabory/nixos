let
vdirsyncerConfig = {
  enable = true;
  collections = [ "from a" ];
  conflictResolution = "remote wins";
  metadata = [
    "color"
    "displayname"
  ];
};
in {
  mkDavAccountSync = label: entry:
  let
    remoteConfig = {
      userName = entry.userName;
      passwordCommand = [
        "cat"
        entry.passwordFile
      ];
    };
  in {
    accounts = {
      calendar.accounts.${label} = {
        remote = remoteConfig // {
          url = entry.calurl;
          type = "caldav";
        };
        vdirsyncer = vdirsyncerConfig;
        khal = {
          enable = true;
          type = "discover";
        };
      };

      contact.accounts.${label} = {
        remote = remoteConfig // {
          url = entry.cardurl;
          type = "carddav";
        };
        vdirsyncer = vdirsyncerConfig;
        khard.enable = true;
      };
    };
  };
}
