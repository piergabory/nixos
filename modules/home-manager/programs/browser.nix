{ inputs, lib, pkgs, ... }:
with lib;

{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  config = {
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = mkIf pkgs.stdenv.isLinux [ pkgs.firefoxpwa ];

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
        settings = {
          "browser.startup.homepage" = "https://hass.pierr.re";
          "browser.startup.page" = 1;
        };

        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
          sponsorblock
        ];
      };
    };

    stylix.targets.zen-browser.profileNames = [ "default" ];
  };
}
