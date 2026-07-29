{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.mastodon;
in {
  config = mkIf cfg.enable {
    services.restic.backups.mastodon = {
        inherit (config.services.backups) repository passwordFile pruneOpts;

        initialize = true;

        timerConfig = config.services.backups.timerConfig // {
          OnCalendar = "04:00";
        };

        paths = [
          "/var/backup/restic/mastodon"
          "/var/lib/mastodon/public-system"
          "/var/lib/mastodon/secrets"
        ];

        backupPrepareCommand = ''
          rm -rf /var/backup/restic/mastodon
          mkdir -p /var/backup/restic/mastodon
          ${pkgs.util-linux}/bin/runuser -u postgres \
            -- ${config.services.postgresql.package}/bin/pg_dump mastodon \
            > /var/backup/restic/mastodon/mastodon.sql
        '';

        extraBackupArgs = [
          "--tag mastodon"
          "--one-file-system"
        ];
      };
  };
}
