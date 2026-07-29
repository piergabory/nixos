{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;
  mount = cfg.dataDisk.mountPoint;

  # Written next to the repository, in the clear, on purpose. Restic always
  # encrypts; the hard part of an emergency restore is not the cryptography but
  # locating the passphrase while under pressure. The disk lives somewhere
  # trusted, so the passphrase travels with it.
  restoreGuide = pkgs.writeText "RESTORE.md" ''
    # Emergency restore

    This disk holds a restic repository replicating the home-lab backups.
    Everything needed to read it is in this directory. No other machine, key
    or account is required.

    - Repository: ./restic/workstation
    - Password:   ./restic-password.txt
    - Binary:     ./restic-binary

    ## List what is available

        ./restic-binary -r ./restic/workstation --password-file ./restic-password.txt snapshots

    Snapshots are tagged by service: immich, vaultwarden, radicale, authelia,
    actual, mastodon, dawarich, airtrail, jellyfin, pihole, nginx, minecraft,
    home-assistant.

    ## Restore one service

        ./restic-binary -r ./restic/workstation --password-file ./restic-password.txt \
            restore latest --tag vaultwarden --target /tmp/restored

    Files land under /tmp/restored with their original absolute paths, e.g.
    /tmp/restored/var/lib/vaultwarden.

    ## Notes per service

    - immich      Originals are in storage/immich/library. Thumbnails and
                  transcodes are NOT backed up; Immich regenerates them.
                  The database lives in storage/immich/backups as a dump.
    - mastodon    Restore the SQL dump, then load it with psql.
    - dawarich    Same: a plain SQL dump, load with psql.
    - airtrail    SQL dump produced from the containerised Postgres.
    - authelia    db.sqlite3 is a consistent sqlite backup, copy it into place.
    - jellyfin    Configuration and user database only. Media is not backed up.

    ## Verify the repository is intact

        ./restic-binary -r ./restic/workstation --password-file ./restic-password.txt check
  '';
in
{
  config = mkIf cfg.enable {
    fileSystems = mkIf (cfg.dataDisk.device != null) {
      ${mount} = {
        device = cfg.dataDisk.device;
        fsType = cfg.dataDisk.fsType;
        # An unattended machine must boot even with a dead backup drive,
        # otherwise a disk failure also costs remote access.
        options = [
          "nofail"
          "x-systemd.device-timeout=30s"
        ];
      };
    };

    # Deliberately not systemd.tmpfiles: those rules are applied early in boot,
    # before /mnt/backup is mounted, which would create the directory tree on
    # the root filesystem and then hide it under the mount.
    systemd.services.offsite-backup-storage = {
      description = "Prepare the replica disk and publish restore instructions";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];

      unitConfig = optionalAttrs (cfg.dataDisk.device != null) {
        RequiresMountsFor = mount;
        ConditionPathIsMountPoint = mount;
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        install -d -m 0700 ${mount}

        # Earlier revisions installed the restic binary at this path, which is
        # where the repository directory belongs. Clear it out if present.
        if [ -f ${mount}/restic ]; then
          rm -f ${mount}/restic
        fi

        install -d -m 0700 ${mount}/restic

        install -m 0600 ${restoreGuide} ${mount}/RESTORE.md
        install -m 0600 ${cfg.passwordFile} ${mount}/restic-password.txt
        install -m 0700 ${pkgs.restic}/bin/restic ${mount}/restic-binary
      '';
    };
  };
}
