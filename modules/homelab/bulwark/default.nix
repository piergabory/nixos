{ config, lib, pkgs, ... }:

with lib;

let
  lab = config.modules.homelab;
  cfg = config.services.bulwark-lite;
  version = "1.21.2";
  source = pkgs.fetchzip {
    url = "https://github.com/bulwarkmail/webmail/releases/download/${version}/bulwark-lite-${version}.zip";
    hash = "sha256-e0FbgnqEYXSJHxKweyHz11ICMDN9f5yXPvMq6ini+EE=";
    stripRoot = false;
  };
  settings = (pkgs.formats.json { }).generate "bulwark-lite-config.json" {
    appName = "iCloud Mail";
    jmapServerUrl = "https://icloud-jmap.${lab.domain}";
    allowCustomJmapEndpoint = false;
    rememberMeEnabled = false;
    loginShowTotp = false;
  };
  webRoot = pkgs.symlinkJoin {
    name = "bulwark-lite-${version}";
    paths = [ source ];
    postBuild = ''
      rm "$out/config.json"
      ln -s ${settings} "$out/config.json"
    '';
  };
  securityHeaders = ''
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https:; font-src 'self' https: data:; connect-src 'self' https://icloud-jmap.${lab.domain}; frame-src 'self' blob:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'self'; media-src 'self' blob:" always;
  '';
in {
  imports = [
    ./stalwart.nix
    ./legacy-proxy.nix
  ];

  options.services.bulwark-lite.enable = mkEnableOption "Bulwark Lite webmail for iCloud";

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."mail.${lab.domain}" = {
      forceSSL = true;
      enableACME = true;
      root = webRoot;
      extraConfig = securityHeaders + ''
        add_header Cache-Control "no-cache" always;
      '';
      locations = {
        "/_next/static/".extraConfig = securityHeaders + ''
          add_header Cache-Control "public, max-age=31536000, immutable" always;
        '';
        "= /manifest.webmanifest".extraConfig = ''
          types { }
          default_type application/manifest+json;
        '';
        "~ ^/(?<locale>[a-zA-Z-]+)/(?<surface>mail|calendar|contacts|files|settings)(/.*)?$" = {
          tryFiles = "$uri $uri/ $uri/index.html /$locale/$surface/index.html =404";
        };
        "/" = {
          tryFiles = "$uri $uri/ $uri/index.html =404";
          extraConfig = ''
            error_page 404 /404.html;
          '';
        };
      };
    };
  };
}
