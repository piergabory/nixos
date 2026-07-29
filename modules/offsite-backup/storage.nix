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
    - Binary:     ./restic  (statically usable on any x86_64 Linux)

    ## List what is available

        ./restic -r ./restic/workstation --password-file ./restic-password.txt snapshots

    Snapshots are tagged by service: immich, vaultwarden, radicale, authelia,
    actual, mastodon, dawarich, airtrail, jellyfin, pihole, nginx, minecraft,
    home-assistant.

    ## Restore one service

        ./restic -r ./restic/workstation --password-file ./restic-password.txt \
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

        ./restic -r ./restic/workstation --password-file ./restic-password.txt check
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

    systemd.tmpfiles.rules = [
      "d ${mount} 0700 root root -"
      "d ${mount}/restic 0700 root root -"
    ];

    # A 2013 Mac mini has little RAM, and restic's index for a repository this
    # size does not comfortably fit in it during prune.
    swapDevices = [
      {
        device = "/var/swapfile";
        size = 4096;
      }
    ];

    systemd.services.offsite-restore-guide = {
      description = "Publish emergency restore instructions next to the replica";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      unitConfig.ConditionPathIsMountPoint = mkIf (cfg.dataDisk.device != null) mount;

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        install -m 0600 ${restoreGuide} ${mount}/RESTORE.md
        install -m 0600 ${cfg.passwordFile} ${mount}/restic-password.txt
        install -m 0700 ${pkgs.restic}/bin/restic ${mount}/restic
      '';
    };
  };
}
