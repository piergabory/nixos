{ config, lib, pkgs, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.immich;
in {
  config = mkIf cfg.enable {
    services.immich = {
      port = 2283;
      host = "127.0.0.1";
      mediaLocation = "/storage/immich";
      environment = {
        IMMICH_URL = "https://photos.${domain}";
        # Force Immich to use integrated GPU (GPU 1) instead of discrete GPU (GPU 0)
        # HIP_VISIBLE_DEVICES accepts device index (0, 1, 2, etc) or "all"
        HIP_VISIBLE_DEVICES = "1";
      };
    };

    users.users.immich.extraGroups = [
      "video"
      "render"
    ];

    systemd = {
      services.immich-server.serviceConfig.ExecStartPre = [
        "+${pkgs.coreutils}/bin/chmod o+x /storage"
      ];
      tmpfiles.rules = [
        "d /storage/immich 0750 immich immich -"
      ];
    };

    environment.systemPackages = with pkgs; [
      immich-cli
    ];

    services.nginx.virtualHosts."photos.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
