{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.homelab.offsiteAccess;

  sendCommand = pkgs.writeShellScript "offsite-status-report" ''
    set -euo pipefail

    if [ ! -e ${cfg.statusFile} ]; then
      echo "No status has been received from the replica yet." \
        | ${cfg.mailScript} "Offsite backup status: nothing reported yet"
      exit 0
    fi

    age_days=$(( ( $(${pkgs.coreutils}/bin/date +%s) \
                 - $(${pkgs.coreutils}/bin/stat -c %Y ${cfg.statusFile}) ) / 86400 ))

    # The body is composed on the replica, which is the only machine that can
    # see its own disk. This side only decides when to send it.
    {
      ${pkgs.coreutils}/bin/cat ${cfg.statusFile}
      echo
      echo "-- "
      echo "Reported $age_days day(s) ago."
      echo "ssh piergabory@offsite.pierr.re"
    } | ${cfg.mailScript} "Offsite backup status"
  '';
in
{
  options.modules.homelab.offsiteAccess.statusReport = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Mail a periodic summary of the offsite replica: disk usage, drive
        health and what it currently holds. Distinct from the deadman, which
        only speaks up when something is wrong.
      '';
    };

    onCalendar = mkOption {
      type = types.str;
      default = "monthly";
      example = "Mon *-*-* 08:00:00";
      description = "How often to mail the status summary.";
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "1h";
      description = "Jitter applied to the status report timer.";
    };
  };

  config = mkIf (cfg.enable && cfg.statusReport.enable) {
    systemd.services.offsite-status-report = {
      description = "Mail the latest status reported by the offsite replica";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = sendCommand;
      };
    };

    systemd.timers.offsite-status-report = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.statusReport.onCalendar;
        RandomizedDelaySec = cfg.statusReport.randomizedDelaySec;
        Persistent = true;
        Unit = "offsite-status-report.service";
      };
    };
  };
}
