let
  homelabDomain = "pierr.re";
  position = 400;
in
{
  programs.zen-browser.profiles.default.spaces.general.pins."Home Lab" = {
    inherit position;
    id = "homelab_group";
    isFolderCollapsed = false;
    pins = {
      "Vault" = {
        id = "homelab_password_vault";
        url = "https://vault.${homelabDomain}";
        position = position + 1;
      };
      "Home" = {
        id = "homelab_home_assistant";
        url = "https://hass.${homelabDomain}/home/overview";
        position = position + 2;
      };
      "Photos" = {
        id = "homelab_photo_library";
        url = "https://photos.${homelabDomain}/photos";
        position = position + 3;
      };
      "Jellyfin" = {
        id = "homelab_media_library";
        url = "https://jelly.${homelabDomain}/web/#/home";
        position = position + 4;
      };
      "Location History" = {
        id = "homelab_location_history";
        url = "https://geo.${homelabDomain}/map/v2";
        position = position + 7;
      };
      "Flights" = {
        id = "homelab_flights_history";
        url = "https://flights.${homelabDomain}";
        position = position + 8;
      };
      "Auth" = {
        id = "homelab_oauth";
        url = "https://auth.${homelabDomain}/settings";
        position = position + 9;
      };
      "CardDav/CalDav Server" = {
        id = "homelab_dav";
        url = "https://dav.${homelabDomain}/radicale/.web/";
        position = position + 10;
      };
      "Home Page" = {
        id = "domain_homepage";
        url = "https://www.${homelabDomain}";
        position = position + 11;
      };
    };
  };
}
