{ config, lib, ... }:
with lib;

let
  cfg = config.services.pihole;
in
{
  config = mkIf cfg.enable {
    services.restic.backups.pihole = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;

      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "03:55";
      };

      paths = [
        "/var/lib/pihole"
      ];

      # pihole-FTL.db is the query log: hundreds of megabytes of telemetry that
      # is worthless in a restore. gravity.db is kept because it also holds the
      # hand-written allow/deny rules and group assignments, which are not
      # reproducible from the Nix configuration.
      exclude = [
        "/var/lib/pihole/pihole-FTL.db*"
        "/var/lib/pihole/gravity_old.db"
        "/var/lib/pihole/gravity_backups"
        "/var/lib/pihole/listsCache"
        "/var/lib/pihole/macvendor.db"
      ];

      extraBackupArgs = [
        "--tag pihole"
        "--one-file-system"
      ];
    };
  };
}
