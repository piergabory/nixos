{ ... }:

{
  programs.zen-browser.profiles.default.pins = {
    "The Verge" = rec {
      url = "https://www.theverge.com/";
      id = url;
    };
    "NYT" = rec {
      url = "https://www.nytimes.com/";
      id = url;
    };
    "Le Monde" = rec {
      url = "https://www.lemonde.fr/";
      id = url;
    };
    "Youtube" = rec {
      url = "https://www.youtube.com/feed/subscriptions";
      id = url;
    };
    "Reddit" = rec {
      url = "https://old.reddit.com/r/unixporn";
      id = url;
    };
    "Home Assistant" = rec {
      url = "https://hass.piergabory.net/dashboard-areas/home";
      id = url;
    };
    "Jellyfin" = rec {
      url = "https://jelly.piergabory.net/web/#/home";
      id = url;
    };
    "Vault" = rec {
      url = "https://vault.piergabory.net/#/vault";
      id = url;
    };
    "Photos" = rec {
      url = "https://photo.piergabory.net/photos";
      id = url;
    };
    "Syncthing" = rec {
      url = "https://sync.piergabory.net";
      id = url;
    };
  };
}
