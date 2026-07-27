{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.minecraft-server;
in {
   services.restic.backups.minecraft = mkIf cfg.enable {
     inherit (config.services.backups) repository passwordFile pruneOpts;
     initialize = true;
     timerConfig = config.services.backups.timerConfig // {
       OnCalendar = "03:00";
     };
     paths = [
       "/var/lib/minecraft/world"
     ];
     backupPrepareCommand = ''
       if ${pkgs.systemd}/bin/systemctl is-active --quiet minecraft-server.service; then
         touch /run/restic-backups-minecraft/minecraft-was-active
         ${pkgs.systemd}/bin/systemctl stop minecraft-server.service
       fi
     '';
     backupCleanupCommand = ''
       if [ -e /run/restic-backups-minecraft/minecraft-was-active ]; then
         rm /run/restic-backups-minecraft/minecraft-was-active
         ${pkgs.systemd}/bin/systemctl start minecraft-server.service
       fi
     '';
     extraBackupArgs = [
       "--tag minecraft"
       "--one-file-system"
     ];
   };
 }
