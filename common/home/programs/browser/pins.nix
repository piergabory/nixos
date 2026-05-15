{ ... }:

let
  spaceId = "a0000000-0000-4000-8000-000000000001";
  containerId = 1;
in
{
  programs.zen-browser.profiles.default.pins =
    let
      news = {
        id = "a1b2c3d4-0001-4000-8000-000000000001";
        isGroup = true;
        isFolderCollapsed = true;
        editedTitle = true;
        position = 100;
        workspace = spaceId;
        container = containerId;
      };
      media = {
        id = "a1b2c3d4-0002-4000-8000-000000000002";
        isGroup = true;
        isFolderCollapsed = true;
        editedTitle = true;
        position = 200;
        workspace = spaceId;
        container = containerId;
      };
      hosted = {
        id = "a1b2c3d4-0003-4000-8000-000000000003";
        isGroup = true;
        isFolderCollapsed = true;
        editedTitle = true;
        position = 300;
        workspace = spaceId;
        container = containerId;
      };
      nixDev = {
        id = "d85a9026-1458-4db6-b115-346746bcc692";
        isGroup = true;
        isFolderCollapsed = true;
        editedTitle = true;
        position = 400;
        workspace = spaceId;
        container = containerId;
      };
      finance = {
        id = "a1b2c3d4-0003-4000-8000-000000000005";
        isGroup = true;
        isFolderCollapsed = true;
        editedTitle = true;
        position = 500;
        workspace = spaceId;
        container = containerId;
      };
    in
    {
      "News" = news;
      "Media" = media;
      "Self-Hosted" = hosted;
      "Nix Dev" = nixDev;
      "Finance" = finance;

      "Github" = rec {
        url = "https://www.github.com/";
        id = url;
        isEssential = true;
        workspace = spaceId;
        container = containerId;
      };
      "The Verge" = rec {
        url = "https://www.theverge.com/";
        id = url;
        folderParentId = news.id;
        position = 101;
        workspace = spaceId;
        container = containerId;
      };
      "NYT" = rec {
        url = "https://www.nytimes.com/";
        id = url;
        folderParentId = news.id;
        position = 102;
        workspace = spaceId;
        container = containerId;
      };
      "Le Monde" = rec {
        url = "https://www.lemonde.fr/";
        id = url;
        folderParentId = news.id;
        position = 103;
        workspace = spaceId;
        container = containerId;
      };
      "Youtube" = rec {
        url = "https://www.youtube.com/feed/subscriptions";
        id = url;
        folderParentId = media.id;
        position = 201;
        workspace = spaceId;
        container = containerId;
      };
      "Nebula" = rec {
        url = "https://www.nebula.tv";
        id = url;
        folderParentId = media.id;
        position = 202;
        workspace = spaceId;
        container = containerId;
      };
      "Reddit" = rec {
        url = "https://old.reddit.com/r/unixporn";
        id = url;
        folderParentId = media.id;
        position = 203;
        workspace = spaceId;
        container = containerId;
      };
      "Instagram" = rec {
        url = "https://www.instagram.com";
        id = url;
        folderParentId = media.id;
        position = 204;
        workspace = spaceId;
        container = containerId;
      };
      "Home Assistant" = rec {
        url = "https://home.piergabory.net/home/overview";
        id = url;
        folderParentId = hosted.id;
        position = 301;
        workspace = spaceId;
        container = containerId;
      };
      "Jellyfin" = rec {
        url = "https://jelly.piergabory.net/web/#/home";
        id = url;
        folderParentId = hosted.id;
        position = 302;
        workspace = spaceId;
        container = containerId;
      };
      "Vault" = rec {
        url = "https://vault.piergabory.net/#/vault";
        id = url;
        folderParentId = hosted.id;
        position = 303;
        workspace = spaceId;
        container = containerId;
      };
      "Photos" = rec {
        url = "https://photo.piergabory.net/photos";
        id = url;
        folderParentId = hosted.id;
        position = 304;
        workspace = spaceId;
        container = containerId;
      };
      "Syncthing" = rec {
        url = "https://sync.piergabory.net";
        id = url;
        folderParentId = hosted.id;
        position = 305;
        workspace = spaceId;
        container = containerId;
      };
      "Actual" = rec {
        url = "https://budget.piergabory.net/budget";
        id = url;
        folderParentId = hosted.id;
        position = 306;
        workspace = spaceId;
        container = containerId;
      };
      "Nix Packages" = {
        id = "f8dd784e-11d7-430a-8f57-7b05ecdb4c77";
        folderParentId = nixDev.id;
        url = "https://search.nixos.org/packages?channel=unstable";
        position = 401;
        workspace = spaceId;
        container = containerId;
      };
      "Nix Options" = {
        id = "92931d60-fd40-4707-9512-a57b1a6a3919";
        folderParentId = nixDev.id;
        url = "https://search.nixos.org/options";
        position = 402;
        workspace = spaceId;
        container = containerId;
      };
      "Home Manager Options" = {
        id = "2eed5614-3896-41a1-9d0a-a3283985359b";
        folderParentId = nixDev.id;
        url = "https://home-manager-options.extranix.com";
        position = 403;
        workspace = spaceId;
        container = containerId;
      };
      "Nixpkgs Reference Manual" = {
        id = "2eb4d13d-2da5-429a-952f-55e2af3e0deb";
        folderParentId = nixDev.id;
        url = "https://nixos.org/manual/nixpkgs/unstable/";
        position = 404;
        workspace = spaceId;
        container = containerId;
      };
      "Nix Wiki" = {
        id = "f8dd784e-11d7-430a-8f57-7b05ecdb4c78";
        folderParentId = nixDev.id;
        url = "https://wiki.nixos.org";
        position = 405;
        workspace = spaceId;
        container = containerId;
      };
      "BoursoBank" = rec {
        url = "https://clients.boursobank.com/";
        id = url;
        folderParentId = finance.id;
        position = 501;
        workspace = spaceId;
        container = containerId;
      };
      "Tradingboard" = rec {
        url = "https://tradingboard.boursobank.com";
        id = url;
        folderParentId = finance.id;
        position = 502;
        workspace = spaceId;
        container = containerId;
      };
      "Discord" = rec {
        url = "https://discord.com/channels/@me"; 
        id = url;
        isEssential = true;
        workspace = spaceId;
        container = containerId;
      };
    };
}
