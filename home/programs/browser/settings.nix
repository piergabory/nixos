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
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];
}
