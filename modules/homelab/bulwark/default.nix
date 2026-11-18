{ config, lib, pkgs, ... }:

with lib;

let
  lab = config.modules.homelab;
  cfg = config.services.bulwark;
in {
  imports = [
    ./stalwart.nix
    ./legacy-proxy.nix
  ];

  config = mkIf cfg.enable {
    services = {
      bulwark = {
        hostname = "localhost";
        port = 3002;
        plugins = [
          { package = pkgs.bulwark-plugins.calendar-agenda; }
          { package = pkgs.bulwark-plugins.gravatar; }
        ];
        settings = {
          jmapServerUrl = "https://jmap.${lab.domain}";
          stalwartFeaturesEnabled = false;

          oauthClientId = "bulwark";
          oauthIssuerUrl = "https://${config.services.authentication.host}";
          oauthScopes = "openid email profile offline_access";

          jmapServers = {
            home = {
              label = "Calendars and contacts";
              url = "https://jmap.${lab.domain}";
              domains = [ ];
              oauth = {
                clientId = "bulwark";
                issuerUrl = "https://${config.services.authentication.host}";
                buttonLabel = "Sign in with Authelia";
              };
            };
          };
        };
      };

      nginx.virtualHosts."mail.${lab.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${cfg.hostname}:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
