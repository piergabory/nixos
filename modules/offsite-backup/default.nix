{ config, lib, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;
in
{
  imports = [
    ./secrets
    ./storage.nix
    ./pull.nix
    ./maintenance.nix
    ./tunnel.nix
    ./healthcheck.nix
    ./resilience.nix
  ];

  options.modules.offsiteBackup = {
    enable = mkEnableOption "Replicate the home-lab backup repository to this machine";

    repository = mkOption {
      type = types.str;
      default = "${cfg.dataDisk.mountPoint}/restic/workstation";
      defaultText = literalExpression ''"''${dataDisk.mountPoint}/restic/workstation"'';
      description = "Local restic repository holding the replica.";
    };

    passwordFile = mkOption {
      type = types.str;
      default = config.age.secrets.restic-password.path;
      defaultText = literalExpression "config.age.secrets.restic-password.path";
      description = ''
        Repository password. The same password is used for both the source and
        the replica, so a single secret covers the whole chain.
      '';
    };

    dataDisk = {
      device = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/dev/disk/by-uuid/0d1f8a3c-...";
        description = ''
          Dedicated disk holding the replica. Mounted with `nofail`: a failed
          drive must never leave an unattended machine stuck in the bootloader.
          Set to null to keep the repository on the root filesystem.
        '';
      };

      fsType = mkOption {
        type = types.str;
        default = "ext4";
        description = "Filesystem of the replica disk.";
      };

      mountPoint = mkOption {
        type = types.str;
        default = "/mnt/backup";
        description = "Where the replica disk is mounted.";
      };
    };

    source = {
      host = mkOption {
        type = types.str;
        example = "pierr.re";
        description = ''
          Host serving the source repository. Resolves to the LAN address at
          home and to the public address elsewhere, so the same value works in
          both locations.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 22;
        description = "SSH port of the source host.";
      };

      user = mkOption {
        type = types.str;
        default = "resticpull";
        description = "Account on the source host with read access to the repository.";
      };

      path = mkOption {
        type = types.str;
        default = "/storage/backups/restic/workstation";
        description = "Absolute path of the source repository on the source host.";
      };

      hostKey = mkOption {
        type = types.str;
        example = "ssh-ed25519 AAAAC3N...";
        description = ''
          Public host key of the source, pinned into a known_hosts file.
          Without this an unattended machine has no way to detect a
          man-in-the-middle, since nobody is there to answer the prompt.
        '';
      };

      identityFile = mkOption {
        type = types.str;
        default = config.age.secrets.offsite-pull-key.path;
        defaultText = literalExpression "config.age.secrets.offsite-pull-key.path";
        description = "Private key authenticating to the source host.";
      };
    };

    schedule = {
      onCalendar = mkOption {
        type = types.str;
        default = "Sun 04:00";
        example = "hourly";
        description = "systemd calendar expression driving the replication.";
      };

      randomizedDelaySec = mkOption {
        type = types.str;
        default = "1h";
        description = "Jitter applied to the replication timer.";
      };

      persistent = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Run immediately if the machine was powered off when the timer was
          due. This is what makes an unplugged week recover on its own.
        '';
      };
    };

    pruneOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
      ];
      description = "Retention policy applied to the replica.";
    };

    maintenance = {
      pruneOnCalendar = mkOption {
        type = types.str;
        default = "monthly";
        description = "When to expire snapshots and repack the replica.";
      };

      checkOnCalendar = mkOption {
        type = types.str;
        default = "monthly";
        description = "When to verify repository integrity.";
      };

      checkSubset = mkOption {
        type = types.str;
        default = "5%";
        description = ''
          Fraction of pack files whose contents are re-hashed on each check.
          Catches silent corruption on ageing disks before a restore does.
        '';
      };
    };

    tunnel = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Maintain a reverse SSH tunnel to the source host, exposing this
          machine's SSH daemon there. This is the only way back in once the
          machine sits behind somebody else's router.
        '';
      };

      host = mkOption {
        type = types.str;
        default = cfg.source.host;
        defaultText = literalExpression "source.host";
        description = "Host to open the tunnel against.";
      };

      port = mkOption {
        type = types.port;
        default = cfg.source.port;
        defaultText = literalExpression "source.port";
        description = "SSH port of the tunnel host.";
      };

      user = mkOption {
        type = types.str;
        default = "offsitetunnel";
        description = "Account on the tunnel host permitted to open the forward.";
      };

      remotePort = mkOption {
        type = types.port;
        default = 2222;
        description = "Loopback port on the tunnel host mapped to this machine's SSH daemon.";
      };
    };

    report = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Record every successful replication with the source host, which
          raises the alarm if reports stop arriving. This detects the machine
          being unplugged or offline, which a notification sent from here
          cannot.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "offsitereport";
        description = "Account on the source host permitted to record a report.";
      };

      alias = mkOption {
        type = types.str;
        default = "offsite-backup-report";
        internal = true;
        description = "ssh alias used for the report connection.";
      };
    };

    healthcheck = {
      enable = mkEnableOption "Ping an external monitor on replication success and failure";

      urlFile = mkOption {
        type = types.str;
        default = config.age.secrets.offsite-healthcheck-url.path;
        defaultText = literalExpression "config.age.secrets.offsite-healthcheck-url.path";
        description = ''
          File containing the base URL to ping. Kept out of the Nix store
          because it doubles as an authentication token.
        '';
      };

      failSuffix = mkOption {
        type = types.str;
        default = "/fail";
        description = "Appended to the base URL when reporting a failure.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.source.host != "";
        message = "modules.offsiteBackup.source.host must be set.";
      }
      {
        assertion = cfg.source.hostKey != "";
        message = "modules.offsiteBackup.source.hostKey must be set so the source can be authenticated unattended.";
      }
    ];

    # Swap belongs to the host's hardware configuration, not here, but restic
    # is memory-hungry when indexing a repository of this size and the machines
    # this runs on tend to be old and small.
    warnings = optional (config.swapDevices == [ ]) ''
      modules.offsiteBackup is enabled but no swap is configured. restic may be
      killed by the OOM reaper while pruning a large repository.
    '';
  };
}
