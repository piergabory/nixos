{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.services.actual;
in {
  services.restic.backups.actual = mkIf cfg.enable {
    inherit (config.services.backups) repository passwordFile pruneOpts;
    initialize = true;

    timerConfig = config.services.backups.timerConfig // {
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
}
