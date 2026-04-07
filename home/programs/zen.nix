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
        default = "ddg"; #duck duck go
      };
      # extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      #   ublock-origin
      #   bitwarden
      # ];
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_WEBRENDER = "1";
    MOZ_X11_EGL = "1";
    MOZ_ACCELERATED = "1";
  };
}
