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
      settings = {
        "browser.startup.homepage" = "https://hass.pierr.re";
        "browser.startup.page" = 1;
      };
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];
}
