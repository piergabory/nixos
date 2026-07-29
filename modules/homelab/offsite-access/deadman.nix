{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.homelab.offsiteAccess;
  lab = config.modules.homelab;

  stateDirectory = "/var/lib/offsite-report";
  timestampFile = "${stateDirectory}/last-success";

  # The offsite machine's only permitted command. It takes no arguments and can
  # do nothing but record that a replication finished, so a compromised replica
  # gains no foothold here beyond lying about its own health.
  recordCommand = pkgs.writeShellScript "offsite-record-success" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/date --iso-8601=seconds > ${timestampFile}
    echo "recorded"
  '';

  checkCommand = pkgs.writeShellScript "offsite-deadman-check" ''
    set -euo pipefail

    threshold=$(( ${toString cfg.deadman.graceDays} * 86400 ))
    now=$(${pkgs.coreutils}/bin/date +%s)

    if [ -e ${timestampFile} ]; then
      last=$(${pkgs.coreutils}/bin/stat -c %Y ${timestampFile})
      age=$(( now - last ))
      if [ "$age" -lt "$threshold" ]; then
        exit 0
      fi
      subject="Offsite backup is $(( age / 86400 )) days stale"
      detail="Last successful replication: $(${pkgs.coreutils}/bin/cat ${timestampFile})"
    else
      subject="Offsite backup has never reported in"
      detail="No successful replication has ever been recorded."
    fi

    # Composed with printf rather than a heredoc: this script is generated from
    # an indented Nix string, and stray leading whitespace would corrupt the
    # mail headers.
    # -f sets the envelope sender. Without it sendmail derives it from the
    # invoking user, and the relay rejects root@ as not one of its addresses.
    ${pkgs.postfix}/bin/sendmail -t -f ${lab.email} <<< "$(printf '%s\n' \
      "To: ${lab.email}" \
      "From: ${lab.email}" \
      "Subject: $subject" \
      "" \
      "$detail" \
      "Grace period: ${toString cfg.deadman.graceDays} days" \
      "" \
      "The machine may be powered off, disconnected, or failing to replicate." \
      "" \
      "  ssh piergabory@offsite.pierr.re" \
      "  journalctl -u offsite-backup-pull.service")"
  '';
in
{
  options.modules.homelab.offsiteAccess.deadman = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Warn by mail when the offsite replica stops reporting successful
        replications. This catches the machine being unplugged or offline,
        which a failure notification sent by the replica itself cannot.
      '';
    };

    graceDays = mkOption {
      type = types.int;
      default = 10;
      description = ''
        How stale the last successful replication may become before mail is
        sent. Should comfortably exceed the replication interval, so that a
        single missed run does not raise an alarm.
      '';
    };

    onCalendar = mkOption {
      type = types.str;
      default = "daily";
      description = "How often to test the age of the last report.";
    };
  };

  config = mkIf (cfg.enable && cfg.deadman.enable) {
    users.users.${cfg.reportUser} = {
      isSystemUser = true;
      group = cfg.reportUser;
      home = stateDirectory;
      createHome = false;
      shell = "${pkgs.shadow}/bin/nologin";
      openssh.authorizedKeys.keys = map (
        key: ''command="${recordCommand}",restrict ${key}''
      ) cfg.authorizedKeys;
    };

    users.groups.${cfg.reportUser} = { };

    systemd.tmpfiles.rules = [
      "d ${stateDirectory} 0755 ${cfg.reportUser} ${cfg.reportUser} -"
    ];

    systemd.services.offsite-deadman = {
      description = "Warn if the offsite replica has stopped reporting in";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = checkCommand;
      };
    };

    systemd.timers.offsite-deadman = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.deadman.onCalendar;
        Persistent = true;
        Unit = "offsite-deadman.service";
      };
    };
  };
}
