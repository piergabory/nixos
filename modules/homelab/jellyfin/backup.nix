{ config, lib, ... }:
with lib;

let
  cfg = config.services.jellyfin;
in
{
  config = mkIf cfg.enable {
    services.restic.backups.jellyfin = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;

      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "03:50";
      };

      # Configuration and state only: users, credentials, watch history,
      # playlists and server settings. The media library itself is public
      # content that can be re-acquired, and is deliberately left out.
      paths = [
        cfg.configDir
        "${cfg.dataDir}/data"
        "${cfg.dataDir}/root"
        "${cfg.dataDir}/plugins"
      ];

      exclude = [
        cfg.logDir
      ];

      extraBackupArgs = [
        "--tag jellyfin"
        "--one-file-system"
      ];
    };
  };
}
