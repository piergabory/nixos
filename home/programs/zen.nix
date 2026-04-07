{ pkgs, inputs, ... }:

{
  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
    };

    profiles.default = {
      search = {
        force = true;
        default = "ddg"; # duck duck go
      };
      bookmarks = {
        force = true;
        settings = [ ];
      };
      pins = {
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
          url = "https://www.youtube.com/subscriptions";
          id = url;
        };
        "Reddit" = rec {
          url = "https://old.reddit.com/r/unixporn";
          id = url;
        };
        "Home Assistant" = rec {
          url = "https://hass.piergabory.net";
          id = url;
        };
        "Jellyfin" = rec {
          url = "https://jelly.piergabory.net";
          id = url;
        };
        "Vault" = rec {
          url = "https://vault.piergabory.net";
          id = url;
        };
        "Photos" = rec {
          url = "https://photo.piergabory.net";
          id = url;
        };
        "Syncthing" = rec {
          url = "https://sync.piergabory.net";
          id = url;
        };
      };
      # extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      #   ublock-origin
      #   dearrow
      #   bitwarden
      # ];
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];
}
