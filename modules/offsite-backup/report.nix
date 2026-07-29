{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;

  # Composed here rather than on the home-lab: this is the only machine that
  # can see its own disk, drive health and replica contents.
  statusScript = pkgs.writeShellScript "offsite-status" ''
    set -uo pipefail
    export RESTIC_CACHE_DIR=/var/cache/offsite-backup

    echo "Host:      $(${pkgs.nettools}/bin/hostname)"
    echo "Reported:  $(${pkgs.coreutils}/bin/date --iso-8601=seconds)"
    echo "Uptime:    $(${pkgs.procps}/bin/uptime -p 2>/dev/null || echo unknown)"
    echo

    echo "== Replica disk =="
    ${pkgs.coreutils}/bin/df -h ${cfg.dataDisk.mountPoint} | ${pkgs.gnused}/bin/sed 1d
    echo

    echo "== Drive health =="
    ${optionalString (cfg.dataDisk.device != null) ''
      part=$(${pkgs.coreutils}/bin/realpath ${cfg.dataDisk.device} 2>/dev/null || true)
      if [ -n "$part" ]; then
        parent=$(${pkgs.util-linux}/bin/lsblk -no pkname "$part" 2>/dev/null | ${pkgs.coreutils}/bin/head -1)
        if [ -n "$parent" ]; then
          disk="/dev/$parent"
          echo "Device: $disk"
          ${pkgs.smartmontools}/bin/smartctl -H "$disk" 2>&1 \
            | ${pkgs.gnugrep}/bin/grep -iE "result|health" || echo "health unavailable"
          # The attributes that actually predict failure on an ageing drive.
          ${pkgs.smartmontools}/bin/smartctl -A "$disk" 2>/dev/null \
            | ${pkgs.gnugrep}/bin/grep -iE "Reallocated_Sector|Current_Pending|Offline_Uncorrectable|Power_On_Hours|Temperature_Celsius" \
            || true
        fi
      fi
    ''}
    echo

    echo "== Replica contents =="
    ${pkgs.restic}/bin/restic -r ${cfg.repository} \
      --password-file ${cfg.passwordFile} \
      snapshots --latest 1 --group-by tags --compact 2>&1 \
      | ${pkgs.gnugrep}/bin/grep -E "^[0-9a-f]{8}" \
      | ${pkgs.gawk}/bin/awk '{ printf "%-14s %s %s  %s %s\n", $5, $2, $3, $6, $7 }' \
      || echo "unable to list snapshots"
    echo

    # grep -c prints 0 and exits non-zero when nothing matches, so a fallback
    # via || would append to the count rather than replace it.
    total=$(${pkgs.restic}/bin/restic -r ${cfg.repository} \
      --password-file ${cfg.passwordFile} snapshots 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -c -E "^[0-9a-f]{8}" || true)
    echo "Snapshots held: ''${total:-0}"
    echo

    echo "== Last replication =="
    ${pkgs.systemd}/bin/systemctl show offsite-backup-pull.service \
      -p Result -p ExecMainStartTimestamp --value 2>/dev/null || true
  '';
in
{
  config = mkIf (cfg.enable && cfg.report.enable) {
    # Report success back to the home-lab, which raises the alarm if reports
    # stop arriving and mails a periodic summary. Unlike a notification sent
    # from here, this also catches the machine being unplugged, offline or dead.
    systemd.services.offsite-backup-report = {
      description = "Report replication status to the home-lab";

      serviceConfig = {
        Type = "oneshot";
        CacheDirectory = "offsite-backup";

        # The far end forces its own command, so nothing chosen here decides
        # what runs there. Retry briefly: a report lost to a flaky link would
        # otherwise look like a failure days later.
        ExecStart = "${pkgs.writeShellScript "offsite-send-report" ''
          set -euo pipefail
          ${statusScript} | ${cfg.sshWrapper}/bin/ssh -o ConnectTimeout=30 ${cfg.report.alias}
        ''}";

        Restart = "on-failure";
        RestartSec = "5m";
      };

      unitConfig.StartLimitBurst = 5;
    };

    systemd.services.offsite-backup-pull.onSuccess = [ "offsite-backup-report.service" ];
  };
}
