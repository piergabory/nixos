{ ... }:

{
  programs.zen-browser.profiles.default.pins = {
    "News" = {
      id = "news";
      isGroup = true;
    };
    "Self-Hosted" = {
      id = "hosted";
      isGroup = true;
    };
    "Media" = {
      id = "media";
      isGroup = true;
    };

    
    "Github" = rec {
      url = "https://www.github.com/";
      id = url;
      isEssential = true;
    };
    "The Verge" = rec {
      url = "https://www.theverge.com/";
      id = url;
      folderParentId = "news";
    };
    "NYT" = rec {
      url = "https://www.nytimes.com/";
      id = url;
      folderParentId = "news";
    };
    "Le Monde" = rec {
      url = "https://www.lemonde.fr/";
      id = url;
      folderParentId = "news";
    };
    "Youtube" = rec {
      url = "https://www.youtube.com/feed/subscriptions";
      id = url;
      folderParentId = "media";
    };
    "Reddit" = rec {
      url = "https://old.reddit.com/r/unixporn";
      id = url;
      folderParentId = "media";
    };
    "Instagram" = rec {
      url = "https://www.instagram.com";
      id = url;
      folderParentId = "media";
    };
    "Nebula" = rec {
      url = "https://www.nebula.tv";
      id = url;
      folderParentId = "media";
    };
    "Home Assistant" = rec {
      url = "https://hass.piergabory.net/dashboard-areas/home";
      id = url;
      folderParentId = "hosted";
      isEssential = true;
    };
    "Jellyfin" = rec {
      url = "https://jelly.piergabory.net/web/#/home";
      id = url;
      folderParentId = "hosted";
    };
    "Vault" = rec {
      url = "https://vault.piergabory.net/#/vault";
      id = url;
      folderParentId = "hosted";
    };
    "Photos" = rec {
      url = "https://photo.piergabory.net/photos";
      id = url;
      folderParentId = "hosted";
    };
    "Syncthing" = rec {
      url = "https://sync.piergabory.net";
      id = url;
      folderParentId = "hosted";
    };
  };
}
