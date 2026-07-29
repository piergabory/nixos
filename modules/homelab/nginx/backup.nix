{ config, lib, ... }:
with lib;

let
  cfg = config.services.nginx;
in
{
  config = mkIf cfg.enable {
    services.restic.backups.nginx = {
      inherit (config.services.backups) repository passwordFile pruneOpts;
      initialize = true;

      timerConfig = config.services.backups.timerConfig // {
        OnCalendar = "03:45";
      };

      # ACME account keys and issued certificates. Re-issuing is possible, but
      # restoring these avoids hitting Let's Encrypt rate limits when bringing
      # a large number of virtual hosts back up at once.
      paths = [
        "/var/lib/acme"
        "/var/http/html"
      ];

      exclude = [
        "/var/lib/acme/acme-challenge"
      ];

      extraBackupArgs = [
        "--tag nginx"
        "--one-file-system"
      ];
    };
  };
}
