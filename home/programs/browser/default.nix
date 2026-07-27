{ inputs, config, lib, pkgs, ... }:
with lib;

let
  cfg = config.programs.zen-browser;
in {
  imports = [
    inputs.zen-browser.homeModules.beta
    ./policies.nix
    ./pins
  ];

  config = mkIf cfg.enable {
    programs.zen-browser = {
      nativeMessagingHosts = mkIf pkgs.stdenv.isLinux [ pkgs.firefoxpwa ];

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
