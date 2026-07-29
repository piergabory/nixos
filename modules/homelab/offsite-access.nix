{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.homelab.offsiteAccess;
  backups = config.services.backups;

  # The replica user is chrooted into the parent of the repository, so from its
  # point of view the repository lives at "/<basename>".
  chrootDirectory = builtins.dirOf backups.repository;
  repositoryInChroot = "/" + builtins.baseNameOf backups.repository;
in
{
  options.modules.homelab.offsiteAccess = {
    enable = mkEnableOption "Allow an offsite replica to pull the backup repository";

    replicaUser = mkOption {
      type = types.str;
      default = "resticpull";
      description = "Unprivileged account the offsite host uses to read the repository over SFTP.";
    };

    tunnelUser = mkOption {
      type = types.str;
      default = "offsitetunnel";
      description = "Unprivileged account the offsite host uses to open its reverse SSH tunnel.";
    };

    tunnelPort = mkOption {
      type = types.port;
      default = 2222;
      description = ''
        Loopback port on this machine that the offsite host forwards its own
        SSH daemon to. Reachable as localhost:this, and nothing else.
      '';
    };

    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Public keys of the offsite host, granted both roles.";
    };

    repositoryPath = mkOption {
      type = types.str;
      readOnly = true;
      default = repositoryInChroot;
      description = "Repository path as seen by the replica user, for use in its restic URL.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.replicaUser} = {
      isSystemUser = true;
      group = backups.group;
      home = chrootDirectory;
      createHome = false;
      shell = "${pkgs.shadow}/bin/nologin";
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    users.users.${cfg.tunnelUser} = {
      isSystemUser = true;
      group = cfg.tunnelUser;
      home = "/var/empty";
      createHome = false;
      shell = "${pkgs.shadow}/bin/nologin";
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    users.groups.${cfg.tunnelUser} = { };

    # AllowUsers defaults to the main user only, which would reject both of
    # these accounts before their Match blocks are ever consulted.
    services.openssh.settings.AllowUsers = [
      cfg.replicaUser
      cfg.tunnelUser
    ];

    services.openssh.extraConfig = ''
      Match User ${cfg.replicaUser}
        ChrootDirectory ${chrootDirectory}
        ForceCommand internal-sftp
        AllowTcpForwarding no
        AllowAgentForwarding no
        X11Forwarding no
        PermitTTY no

      Match User ${cfg.tunnelUser}
        ForceCommand ${pkgs.coreutils}/bin/false
        AllowTcpForwarding remote
        PermitOpen none
        PermitListen 127.0.0.1:${toString cfg.tunnelPort} localhost:${toString cfg.tunnelPort}
        AllowAgentForwarding no
        X11Forwarding no
        PermitTTY no
        GatewayPorts no
    '';
  };
}
