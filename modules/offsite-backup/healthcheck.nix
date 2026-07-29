{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;

  ping = pkgs.writeShellScript "offsite-healthcheck-ping" ''
    set -euo pipefail
    suffix="''${1:-}"
    url="$(tr -d '[:space:]' < ${cfg.healthcheck.urlFile})"
    [ -n "$url" ] || exit 0
    ${pkgs.curl}/bin/curl \
      --silent --show-error \
      --retry 5 --retry-delay 30 --retry-connrefused \
      --max-time 30 \
      --output /dev/null \
      "''${url}''${suffix}"
  '';

  pingUnit = name: args: {
    description = "Report replication ${name} to the external monitor";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ping} ${args}";
    };
  };
in
{
  config = mkMerge [
    # Report success back to the home-lab, which raises the alarm if reports
    # stop arriving. Unlike a failure notification sent from here, this also
    # catches the machine being unplugged, offline, or dead.
    (mkIf (cfg.enable && cfg.report.enable) {
      systemd.services.offsite-backup-report = {
        description = "Record a successful replication with the home-lab";

        serviceConfig = {
          Type = "oneshot";
          # The far end forces its own command, so nothing here is trusted to
          # choose what runs. Retry briefly: a report lost to a flaky link
          # would otherwise look like a failure a few days later.
          ExecStart = "${cfg.sshWrapper}/bin/ssh -o ConnectTimeout=30 ${cfg.report.alias} true";
          Restart = "on-failure";
          RestartSec = "5m";
        };

        unitConfig.StartLimitBurst = 5;
      };

      systemd.services.offsite-backup-pull.onSuccess = [ "offsite-backup-report.service" ];
    })

    (mkIf (cfg.enable && cfg.healthcheck.enable) {
      systemd.services.offsite-healthcheck-success = pingUnit "success" "";
      systemd.services.offsite-healthcheck-failure = pingUnit "failure" cfg.healthcheck.failSuffix;

      systemd.services.offsite-backup-pull = {
        onSuccess = [ "offsite-healthcheck-success.service" ];
        onFailure = [ "offsite-healthcheck-failure.service" ];
      };

      systemd.services.offsite-backup-check.onFailure = [ "offsite-healthcheck-failure.service" ];
    })

    (mkIf cfg.enable {
      # An ageing spinning disk is the weakest component here.
      services.smartd.enable = mkDefault true;
    })
  ];
}
