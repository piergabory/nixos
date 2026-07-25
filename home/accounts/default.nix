let
  thunderbird = {
    enable = true;
    profiles = [ "default" ];
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
in
{
  imports = [
    ./secrets
  ];

  config = {
    programs.thunderbird.profiles.default.isDefault = true;
    accounts = {
      calendar.accounts.homelab = {
        inherit vdirsyncer thunderbird;
        remote = {
          type = "caldav";
          url = "https://dav.pierr.re/radicale/piergabory/CA29734E-8D86-4B4C-AEA1-EE1B0A1FB602/";
          userName = "piergabory";
        };
        khal = {
          enable = true;
          type = "discover";
        };
      };

      contact.accounts.homelab = {
        inherit vdirsyncer thunderbird;
        remote = {
          type = "carddav";
          url = "https://dav.pierr.re/radicale/piergabory/0ac941e4-dfed-8c95-0f98-97f88d7ab88b/";
          userName = "piergabory";
        };
        khard.enable = true;
      };
    };
  };
}
