let
  homelabDomain = "pierr.re";
  position = 400;
in {
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
        url = "https://hass.${homelabDomain}";
        position = position + 2;
      };
      "Photos" = {
        id = "homelab_photo_library";
        url = "https://photos.${homelabDomain}";
        position = position + 3;
      };
      "Jellyfin" = {
        id = "homelab_media_library";
        url = "https://jelly.${homelabDomain}";
        position = position + 4;
      };
      "Mastodon" = {
        id = "homelab_mastodon_instance";
        url = "https://mas.${homelabDomain}";
        position = position + 5;
      };
      "Budget" = {
        id = "homelab_budgeting_tool";
        url = "https://budget.${homelabDomain}";
        position = position + 6;
      };
      "Location History" = {
        id = "homelab_location_history";
        url = "https://geo.${homelabDomain}";
        position = position + 7;
      };
      "Flights" = {
        id = "homelab_flights_history";
        url = "https://flights.${homelabDomain}";
        position = position + 8;
      };
      "Auth" = {
        id = "homelab_oauth";
        url = "https://auth.${homelabDomain}";
        position = position + 9;
      };
      "CardDav/CalDav Server" = {
        id = "homelab_dav";
        url = "https://dav.${homelabDomain}";
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
