{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;
  mount = cfg.dataDisk.mountPoint;
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
      description = "Prepare the replica disk";
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

        install -m 0700 ${pkgs.restic}/bin/restic ${mount}/restic-binary
      '';
    };
  };
}
