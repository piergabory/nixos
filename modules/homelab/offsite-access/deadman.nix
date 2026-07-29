{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.homelab.offsiteAccess;

  checkCommand = pkgs.writeShellScript "offsite-deadman-check" ''
    set -euo pipefail

    threshold=$(( ${toString cfg.deadman.graceDays} * 86400 ))
    now=$(${pkgs.coreutils}/bin/date +%s)

    if [ -e ${cfg.timestampFile} ]; then
      last=$(${pkgs.coreutils}/bin/stat -c %Y ${cfg.timestampFile})
      age=$(( now - last ))
      if [ "$age" -lt "$threshold" ]; then
        exit 0
      fi
      subject="Offsite backup is $(( age / 86400 )) days stale"
    else
      subject="Offsite backup has never reported in"
    fi

    {
      if [ -e ${cfg.timestampFile} ]; then
        echo "Last successful replication: $(${pkgs.coreutils}/bin/cat ${cfg.timestampFile})"
      else
        echo "No successful replication has ever been recorded."
      fi
      echo "Grace period: ${toString cfg.deadman.graceDays} days"
      echo
      echo "The machine may be powered off, disconnected, or failing to replicate."
      echo
      echo "  ssh piergabory@offsite.pierr.re"
      echo "  journalctl -u offsite-backup-pull.service"
    } | ${cfg.mailScript} "$subject"
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
