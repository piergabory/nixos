{ config, pkgs, ... }:

{
  services.actual = {
    enable = true;
    settings = {
      port = 3000;
      hostname = "127.0.0.1";
    };
  };

  services.restic.backups.actual = {
    inherit (config.piergabory.backups) repository passwordFile pruneOpts;
    initialize = true;
    timerConfig = config.piergabory.backups.timerConfig // {
      OnCalendar = "03:40";
    };
    paths = [
      "/var/backup/restic/actual"
    ];
    backupPrepareCommand = ''
      rm -rf /var/backup/restic/actual
      mkdir -p /var/backup/restic/actual
      if ${pkgs.systemd}/bin/systemctl is-active --quiet actual.service; then
        touch /run/restic-backups-actual/actual-was-active
        ${pkgs.systemd}/bin/systemctl stop actual.service
      fi
      cp -a /var/lib/actual/. /var/backup/restic/actual/
    '';
    backupCleanupCommand = ''
      if [ -e /run/restic-backups-actual/actual-was-active ]; then
        rm /run/restic-backups-actual/actual-was-active
        ${pkgs.systemd}/bin/systemctl start actual.service
      fi
    '';
    extraBackupArgs = [
      "--tag actual"
      "--one-file-system"
    ];
  };

  services.nginx.virtualHosts = {
    "budget.piergabory.net" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
