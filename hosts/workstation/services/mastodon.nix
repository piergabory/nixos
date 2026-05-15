{ config, ... }:

{
  services.mastodon = {
    enable = true;
    localDomain = "masto.piergabory.net";
    configureNginx = true;
    smtp.fromAddress = "noreply@piergabory.net";
    streamingProcesses = 1;
    extraConfig.SINGLE_USER_MODE = "true";
  };

  services.restic.backups.mastodon = {
    inherit (config.piergabory.backups) repository passwordFile pruneOpts;
    initialize = true;
    timerConfig = config.piergabory.backups.timerConfig // {
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
      ${config.services.postgresql.package}/bin/pg_dump mastodon > /var/backup/restic/mastodon/mastodon.sql
    '';
    extraBackupArgs = [
      "--tag mastodon"
      "--one-file-system"
    ];
  };
}
