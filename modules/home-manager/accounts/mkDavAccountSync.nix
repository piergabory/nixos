{
  label,
  userName,
  passwordFile,
  calurl,
  cardurl,
}:
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
  remoteConfig = {
    inherit userName;
    passwordCommand = [
      "cat"
      passwordFile
    ];
  };
in
{
  accounts = {
    calendar.accounts.${label} = {
      remote = remoteConfig // {
        url = calurl;
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
        url = cardurl;
        type = "carddav";
      };
      vdirsyncer = vdirsyncerConfig;
      khard.enable = true;
    };
  };
}
