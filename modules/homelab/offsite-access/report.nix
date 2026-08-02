{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.homelab.offsiteAccess;
  lab = config.modules.homelab;

  stateDirectory = "/var/lib/offsite-report";

  # The offsite machine's only permitted command. It records that a replication
  # finished and stores whatever status text was piped to it, and can do nothing
  # else, so a compromised replica gains no foothold here beyond lying about its
  # own health.
  recordCommand = pkgs.writeShellScript "offsite-record-report" ''
    set -euo pipefail
    umask 022

    # Bounded: the sender is remote and this is written to local disk.
    ${pkgs.coreutils}/bin/head -c 65536 > ${cfg.statusFile}.incoming
    ${pkgs.coreutils}/bin/mv ${cfg.statusFile}.incoming ${cfg.statusFile}
    ${pkgs.coreutils}/bin/date --iso-8601=seconds > ${cfg.timestampFile}

    echo "recorded"
  '';
in
{
  options.modules.homelab.offsiteAccess = {
    timestampFile = mkOption {
      type = types.str;
      internal = true;
      default = "${stateDirectory}/last-success";
      description = "Records when the replica last completed a replication.";
    };

    statusFile = mkOption {
      type = types.str;
      internal = true;
      default = "${stateDirectory}/last-status";
      description = "Most recent status report received from the replica.";
    };

    mailScript = mkOption {
      type = types.path;
      internal = true;
      description = "Sends mail about the offsite replica. Subject in $1, body on stdin.";
    };
  };

  config = mkIf cfg.enable {
    # -f sets the envelope sender. Without it sendmail derives it from the
    # invoking user, and the relay rejects root@ as not one of its addresses.
    modules.homelab.offsiteAccess.mailScript = pkgs.writeShellScript "offsite-mail" ''
      set -euo pipefail
      {
        ${pkgs.coreutils}/bin/printf 'To: %s\nFrom: %s\nSubject: %s\n\n' \
          '${lab.email}' '${lab.email}' "$1"
        ${pkgs.coreutils}/bin/cat
      } | ${pkgs.postfix}/bin/sendmail -t -f '${lab.email}'
    '';

    users.users.${cfg.reportUser} = {
      isSystemUser = true;
      group = cfg.reportUser;
      home = stateDirectory;
      createHome = false;
      shell = "${pkgs.bash}/bin/bash";
      openssh.authorizedKeys.keys = map (
        key: ''command="${recordCommand}",restrict ${key}''
      ) cfg.authorizedKeys;
    };

    users.groups.${cfg.reportUser} = { };

    systemd.tmpfiles.rules = [
      "d ${stateDirectory} 0755 ${cfg.reportUser} ${cfg.reportUser} -"
    ];
  };
}
