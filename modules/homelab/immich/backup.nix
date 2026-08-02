{ config, lib, ... }:
with lib;

let
  cfg = config.services.immich;
in
{
  config = mkIf cfg.enable {
    services.restic.backups.immich = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;

      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "02:00";
      };

      paths = [
        "${cfg.mediaLocation}/backups"
        "${cfg.mediaLocation}/library"
        "${cfg.mediaLocation}/profile"
        "${cfg.mediaLocation}/upload"
      ];

      # Derivatives are fully regenerable from the originals, and account for
      # roughly a third of the library on disk. Everything else is kept:
      #   library/  original assets
      #   upload/   assets not yet moved into the library
      #   profile/  user avatars
      #   backups/  Immich's own nightly database dumps
      exclude = [
        "${cfg.mediaLocation}/thumbs"
        "${cfg.mediaLocation}/encoded-video"
      ];

      extraBackupArgs = [
        "--tag immich"
        "--one-file-system"
      ];
    };
  };
}
