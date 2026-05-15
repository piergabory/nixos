{ config, lib, ... }:

let
  inherit (lib) mkOption types;
in

{
  options.piergabory.backups = {
    repository = mkOption {
      type = types.str;
      default = "/storage/backups/restic/workstation";
      description = "Local restic repository for workstation service backups.";
    };

    passwordFile = mkOption {
      type = types.str;
      default = config.age.secrets.restic-password.path;
      description = "Path to the restic repository password file.";
    };

    timerConfig = mkOption {
      type = types.attrs;
      default = {
        OnCalendar = "03:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
      description = "Default timer configuration for restic backups.";
    };

    pruneOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
      ];
      description = "Default retention policy for restic backups.";
    };
  };

  config = {
    age.secrets.restic-password = {
      file = ../secrets/restic-password.age;
      mode = "0600";
    };

    systemd.tmpfiles.rules = [
      "d /storage/backups 0700 root root -"
      "d /storage/backups/restic 0700 root root -"
      "d /storage/backups/restic/workstation 0700 root root -"
      "d /var/backup/restic 0700 root root -"
    ];
  };
}
