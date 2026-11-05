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
    ./stylix.nix
  ];

  config = mkIf cfg.enable {
    services.searx = {
      openFirewall = false;
      configureNginx = false;
      environmentFile = config.age.secrets.searx-env.path;

      settings = {
        server = {
          base_url = "https://${domain}/";
          bind_address = "127.0.0.1";
          port = 8332;
          secret_key = "$SEARXNG_SECRETS";
          image_proxy = true;
        };

        search.default_lang = "en-US";
        ui.default_locale = "en";

        engines = [
          {
            name = "duckduckgo";
            disabled = false;
            weight = 1.5;
          }
          {
            name = "brave";
            disabled = false;
            weight = 1.0;
          }
        ];

        plugins =
          genAttrs
            (map (name: "searx.plugins.${name}.SXNGPlugin") [
              "calculator"
              "infinite_scroll"
              "hash_plugin"
              "self_info"
              "unit_converter"
              "ahmia_filter"
              "hostnames"
              "time_zone"
              "tracker_url_remover"
            ])
            (_: {
              active = true;
            })
          //
            genAttrs
              (map (name: "searx.plugins.${name}.SXNGPlugin") [
                "oa_doi_rewrite"
                "tor_check"
              ])
              (_: {
                active = false;
              });
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
