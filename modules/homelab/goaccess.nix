{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.goaccess;
in
{
  options.services.goaccess = {
    enable = mkEnableOption "Goaccess network statistics services";
    domain = mkOption {
      type = types.str;
    };
    webPort = mkOption {
      type = types.int;
      default = 6876;
    };
    geoipDatabase = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a MaxMind GeoIP database used by GoAccess.";
    };
    maxmindAccountID = mkOption {
      type = types.nullOr types.int;
      default = null;
    };
    maxmindLicenseKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      goaccess
      geoipupdate
    ];

    users.users.goaccess = {
      isSystemUser = true;
      group = "nginx";
      extraGroups = [ "nginx" ];
    };

    services.geoipupdate = mkIf (cfg.maxmindAccountID != null && cfg.maxmindLicenseKeyFile != null) {
      enable = true;
      settings = {
        AccountID = cfg.maxmindAccountID;
        EditionIDs = [ "GeoLite2-City" ];
        LicenseKey = { _secret = cfg.maxmindLicenseKeyFile; };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d /var/lib/goaccess 0750 goaccess nginx -"
      ];

      services.goaccess = {
        description = "GoAccess Nginx log analyser";
        after = [ "nginx.service" "geoipupdate.service" ];
        wants = [ "geoipupdate.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = "goaccess";
          Group = "nginx";
          Restart = "always";
          RestartSec = 5;
        };

        script = ''
          set -o pipefail
          {
            for log in /var/log/nginx/access.log*; do
              case "$log" in
                *.gz) ${pkgs.gzip}/bin/zcat -- "$log" ;;
                *) ${pkgs.coreutils}/bin/cat -- "$log" ;;
              esac
            done
            exec ${pkgs.coreutils}/bin/tail --lines=0 --follow=name \
              /var/log/nginx/access.log
          } | exec ${pkgs.goaccess}/bin/goaccess - \
            --log-format=COMBINED \
            --keep-last=7 \
            ${optionalString (cfg.geoipDatabase != null) "--geoip-database=${cfg.geoipDatabase} \\"}
            --output=/var/lib/goaccess/index.html \
            --real-time-html \
            --addr=127.0.0.1 \
            --port=${toString cfg.webPort} \
            --ws-url=wss://${cfg.domain}:443/goaccess/ws \
            --origin=https://${cfg.domain}
        '';
      };
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = config.modules.oauth.internalAuthLocation;
      locations."/" = {
        alias = "/var/lib/goaccess/";
        extraConfig = config.modules.oauth.forwardAuthConfig;
      };

      locations."/goaccess/ws" = {
        proxyPass = "http://127.0.0.1:${toString cfg.webPort}";
        proxyWebsockets = true;
        extraConfig = config.modules.oauth.forwardAuthConfig;
      };
    };
  };
}
