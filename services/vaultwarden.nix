{ config, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    environmentFile = "/var/lib/vaultwarden/vaultwarden.env";

    config = {
      DOMAIN = "https://vault.piergabory.net";

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SSL = false;
      SMTP_FROM = "vault@piergabory.net";
      SMTP_FROM_NAME = "piergabory.net vaultwarden server";
    };
  };

  services.restic.backups.vaultwarden = {
    inherit (config.piergabory.backups) repository passwordFile pruneOpts;
    initialize = true;
    timerConfig = config.piergabory.backups.timerConfig // {
      OnCalendar = "03:20";
    };
    paths = [
      "/var/backup/vaultwarden"
    ];
    backupPrepareCommand = ''
      ${config.systemd.package}/bin/systemctl start backup-vaultwarden.service
    '';
    extraBackupArgs = [
      "--tag vaultwarden"
      "--one-file-system"
    ];
  };

  services.nginx.virtualHosts."vault.piergabory.net" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8222";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
