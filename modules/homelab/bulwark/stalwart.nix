{ config, lib, pkgs, ... }:

with lib;

let
  domain = "jmap.${config.modules.homelab.domain}";
  port = 3005;
in
{
  imports = [
    ./secrets
  ];

  config = mkIf config.services.bulwark-lite.enable {
    services.stalwart = {
      enable = true;
      stateVersion = "26.05";
      settings = {
        server = {
          hostname = domain;
          listener.http = {
            bind = [ "127.0.0.1:${toString port}" ];
            protocol = "http";
          };
        };
        http = {
          url = "'https://${domain}'";
          use-x-forwarded = true;
          headers = [
            "Access-Control-Allow-Origin: https://mail.${config.modules.homelab.domain}"
            "Access-Control-Allow-Headers: Authorization, Content-Type, Accept, X-Requested-With"
            "Access-Control-Allow-Methods: POST, GET, PATCH, PUT, DELETE, HEAD, OPTIONS"
          ];
        };
        directory.authelia = {
          type = "oidc";
          timeout = "15s";
          endpoint = {
            url = "https://${config.services.authentication.host}/api/oidc/userinfo";
            method = "userinfo";
          };
          fields = {
            email = "email";
            username = "preferred_username";
            full-name = "name";
          };
        };
        storage.directory = "authelia";
        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:${config.age.secrets.stalwart-admin.path}}%";
        };
      };
    };

    services.restic.backups.stalwart = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;
      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "03:35";
      };
      paths = [ "/var/backup/restic/stalwart" ];
      backupPrepareCommand = ''
        set -euo pipefail
        install -d -m 0700 /var/backup/restic/stalwart
        # RocksDB needs a stopped server for a consistent filesystem copy.
        if ${pkgs.systemd}/bin/systemctl is-active --quiet stalwart.service; then
          trap '${pkgs.systemd}/bin/systemctl start stalwart.service' EXIT
          ${pkgs.systemd}/bin/systemctl stop stalwart.service
        fi
        ${pkgs.gnutar}/bin/tar -C /var/lib/stalwart -cf /var/backup/restic/stalwart/data.tar.next .
        mv /var/backup/restic/stalwart/data.tar.next /var/backup/restic/stalwart/data.tar
      '';
      extraBackupArgs = [
        "--tag stalwart"
        "--one-file-system"
      ];
    };
    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50M;
          proxy_buffering off;
          proxy_read_timeout 1h;
        '';
      };
    };
  };
}
