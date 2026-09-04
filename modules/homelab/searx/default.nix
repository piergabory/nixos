{ config, lib, ... }:
with lib;
let
  lab = config.modules.homelab;
  cfg = config.services.searx;
  domain = "search.${lab.domain}";
in
{
  imports = [
    ./secrets
  ];

  config = mkIf cfg.enable {
    services.searx = {
      openFirewall = false;
      configureNginx = false;
      environmentFile = config.age.secrets.searx-env.path;

      settings.server = {
        base_url = "https://${domain}/";
        bind_address = "127.0.0.1";
        port = 8332;
        secret_key = "$SEARXNG_SECRETS";
      };
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = config.modules.oauth.internalAuthLocation;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8332";
          extraConfig = config.modules.oauth.forwardAuthConfig;
        };
        "/static/".alias = "${config.services.searx.package}/share/static/";
      };
    };

  };
}
