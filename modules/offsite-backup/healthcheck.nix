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
    # Optional, and off by default: the home-lab already alerts on missing
    # reports without depending on a third party. This exists for anyone who
    # would rather not have the alarm depend on the machine being replicated.
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
      # An ageing spinning disk is the weakest component here, and its
      # attributes are included in the periodic status report.
      services.smartd.enable = mkDefault true;
    })
  ];
}
