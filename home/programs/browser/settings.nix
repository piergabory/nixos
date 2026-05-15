{ pkgs, ... }:

{
  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];

    profiles.default = {
      search = {
        force = true;
        default = "ddg"; # duck duck go
      };
      bookmarks = {
        force = true;
        settings = [ ];
      };
      settings = {
        "browser.startup.homepage" = "https://dash.piergabory.net";
        "browser.startup.page" = 1;
      };
      pinsForce = true;

      containersForce = true;
      containers."Personal" = {
        id = 1;
        color = "blue";
        icon = "fingerprint";
      };

      spacesForce = true;
      spaces."Personal" = {
        id = "a0000000-0000-4000-8000-000000000001";
        position = 1000;
        container = 1;
      };
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];
}
