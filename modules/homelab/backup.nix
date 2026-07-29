{ config, lib, ... }:

let
  inherit (lib) mkOption types mapAttrs' nameValuePair;
in

{
  options.services.backups = {
    group = mkOption {
      type = types.str;
      default = "restic";
      description = ''
        Group granted read access to the repository. Restic jobs run as root
        and would otherwise create pack files as 0600 root, unreadable by the
        offsite replica user.
      '';
    };

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
    users.groups.${config.services.backups.group} = { };

    # Restic runs as root. Without a relaxed umask the repository is only
    # readable by root, which defeats the point of a dedicated replica user.
    # Combined with the setgid bit below, every new pack file lands in the
    # backup group with group read/write.
    systemd.services = mapAttrs' (
      name: _:
      nameValuePair "restic-backups-${name}" {
        serviceConfig.UMask = "0007";
      }
    ) config.services.restic.backups;

    systemd.tmpfiles.rules = [
      # 0751 on the two parents: traversable, but not listable, by the
      # replica user. /storage/backups/restic doubles as its SSH chroot, so it
      # must stay root-owned and not writable by group or other.
      "d /storage/backups 0751 root root -"
      "d /storage/backups/restic 0751 root root -"
      "d /storage/backups/restic/workstation 2770 root ${config.services.backups.group} -"
      "d /var/backup/restic 0700 root root -"
    ];
  };
}
