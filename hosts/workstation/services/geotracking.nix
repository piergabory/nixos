{ config, pkgs, ... }:

{
  services.dawarich = {
    enable = true;
    localDomain = "geo.pierr.re";
    webPort = 64645;
  };

  services.restic.backups.dawarich = {
    inherit (config.piergabory.backups) repository passwordFile pruneOpts;
    initialize = true;
    timerConfig = config.piergabory.backups.timerConfig // {
      OnCalendar = "04:10";
    };
    paths = [ "/var/backup/restic/dawarich" ];
    backupPrepareCommand = ''
      rm -rf /var/backup/restic/dawarich
      mkdir -p /var/backup/restic/dawarich
      ${pkgs.util-linux}/bin/runuser -u postgres -- ${config.services.postgresql.package}/bin/pg_dump dawarich > /var/backup/restic/dawarich/dawarich.sql
    '';
    extraBackupArgs = [
      "--tag dawarich"
      "--one-file-system"
    ];
  };

  services.nginx.virtualHosts."geo.pierr.re" = {
    serverAliases = [ "geo.piergabory.net" ];
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:64645";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 2048M;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
