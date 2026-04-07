{ ... }:

{
  programs.zen-browser.profiles.default.pins = let
    news = {
      id = "news";
      isGroup = true;
      isFolderCollapsed = false;
      editedTitle = true;
      position = 100;
    };
    media = {
      id = "media";
      isGroup = true;
      isFolderCollapsed = false;
      editedTitle = true;
      position = 200;
    };
    hosted = {
      id = "hosted";
      isGroup = true;
      isFolderCollapsed = false;
      editedTitle = true;
      position = 300;
    };
    nixDev = {
      id = "d85a9026-1458-4db6-b115-346746bcc692";
      isGroup = true;
      isFolderCollapsed = false;
      editedTitle = true;
      position = 204;
    };
  in  {
    "News" = news;
    "Media" = media;
    "Self-Hosted" = hosted;
    "Nix Dev" = nixDev;

    
    "Github" = rec {
      url = "https://www.github.com/";
      id = url;
      isEssential = true;
    };
    "The Verge" = rec {
      url = "https://www.theverge.com/";
      id = url;
      folderParentId = news.id;
      position = 101;
    };
    "NYT" = rec {
      url = "https://www.nytimes.com/";
      id = url;
      folderParentId = news.id;
      position = 102;
    };
    "Le Monde" = rec {
      url = "https://www.lemonde.fr/";
      id = url;
      folderParentId = news.id;
      position = 103;
    };
    "Youtube" = rec {
      url = "https://www.youtube.com/feed/subscriptions";
      id = url;
      folderParentId = media.id;
      position = 201;
    };
    "Nebula" = rec {
      url = "https://www.nebula.tv";
      id = url;
      folderParentId = media.id;
      position = 202;
    };
    "Reddit" = rec {
      url = "https://old.reddit.com/r/unixporn";
      id = url;
      folderParentId = media.id;
      position = 203;
    };
    "Instagram" = rec {
      url = "https://www.instagram.com";
      id = url;
      folderParentId = media.id;
      position = 204;
    };
    "Home Assistant" = rec {
      url = "https://hass.piergabory.net/dashboard-areas/home";
      id = url;
      folderParentId = hosted.id;
      position = 301;
    };
    "Jellyfin" = rec {
      url = "https://jelly.piergabory.net/web/#/home";
      id = url;
      folderParentId = hosted.id;
      position = 302;
    };
    "Vault" = rec {
      url = "https://vault.piergabory.net/#/vault";
      id = url;
      folderParentId = hosted.id;
      position = 303;
    };
    "Photos" = rec {
      url = "https://photo.piergabory.net/photos";
      id = url;
      folderParentId = hosted.id;
      position = 304;
    };
    "Syncthing" = rec {
      url = "https://sync.piergabory.net";
      id = url;
      folderParentId = hosted.id;
      position = 305;
    };
    "Nix Packages" = {
      id = "f8dd784e-11d7-430a-8f57-7b05ecdb4c77";
      folderParentId = nixDev.id;
      url = "https://search.nixos.org/packages";
      position = 205;
    };
    "Nix Options" = {
      id = "92931d60-fd40-4707-9512-a57b1a6a3919";
      folderParentId = nixDev.id;
      url = "https://search.nixos.org/options";
      position = 206;
    };
    "Home Manager Options" = {
      id = "2eed5614-3896-41a1-9d0a-a3283985359b";
      folderParentId = nixDev.id;
      url = "https://home-manager-options.extranix.com";
      position = 207;
    };
    "Nixpkgs Reference Manual" = {
      id = "2eb4d13d-2da5-429a-952f-55e2af3e0deb";
      folderParentId = nixDev.id;
      url = "https://nixos.org/manual/nixpkgs/unstable/";
      position = 208;
    };
  };
}
