{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.modules.homelab.offsiteAccess;
  backups = config.services.backups;
  sourceJobs = filterAttrs (
    _: backup:
    backup.repository == backups.repository
    && ((backup.paths != null && backup.paths != [ ]) || backup.command != null)
  ) config.services.restic.backups;

  checkCommand = pkgs.writeShellScript "offsite-deadman-check" ''
    set -euo pipefail

    issues=()
    threshold=$(( ${toString cfg.deadman.graceDays} * 86400 ))
    snapshot_threshold=$(( 72 * 3600 ))
    now=$(${pkgs.coreutils}/bin/date +%s)

    if [ -e ${cfg.timestampFile} ]; then
      last=$(${pkgs.coreutils}/bin/stat -c %Y ${cfg.timestampFile})
      age=$(( now - last ))
      if [ "$age" -ge "$threshold" ]; then
        issues+=("Offsite replica: last successful report is $(( age / 86400 )) days old (limit: ${toString cfg.deadman.graceDays} days).")
      fi
    else
      issues+=("Offsite replica: no successful replication has ever been recorded.")
    fi

    if snapshots=$(${pkgs.restic}/bin/restic --no-cache \
      -r ${escapeShellArg backups.repository} \
      --password-file ${escapeShellArg backups.passwordFile} \
      snapshots --json --latest 1 --group-by tags 2>&1); then
      if ${pkgs.jq}/bin/jq -e '
        type == "array" and all(.[];
          type == "object"
          and (.tags // [] | type == "array" and all(.[]; type == "string"))
          and (.time | type == "string" and test(
            "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})$"
          ))
        )
      ' >/dev/null 2>&1 <<< "$snapshots"; then
        for tag in ${escapeShellArgs (attrNames sourceJobs)}; do
          if latest=$(${pkgs.jq}/bin/jq -er --arg tag "$tag" '
            [.[] | select((.tags // []) | index($tag)) | .time] | max // empty
          ' <<< "$snapshots"); then
            if timestamp=$(${pkgs.coreutils}/bin/date --date="$latest" +%s 2>/dev/null); then
              age=$(( now - timestamp ))
              if [ "$age" -gt "$snapshot_threshold" ]; then
                issues+=("Source backup $tag: newest snapshot is $(( age / 3600 )) hours old (limit: 72 hours).")
              fi
            else
              issues+=("Source backup $tag: unable to parse snapshot time: $latest")
            fi
          else
            issues+=("Source backup $tag: no usable snapshot found.")
          fi
        done
      else
        issues+=("Source repository: restic returned invalid snapshot JSON.")
      fi
    else
      issues+=("Source repository: unable to inspect snapshots." "$snapshots")
    fi

    if [ "''${#issues[@]}" -eq 0 ]; then
      exit 0
    fi

    {
      printf '%s\n' "''${issues[@]}"
      echo
      echo "Inspect source jobs with: journalctl -u 'restic-backups-*'"
      echo "Inspect replication with:"
      echo
      echo "  ssh piergabory@offsite.pierr.re"
      echo "  journalctl -u offsite-backup-pull.service"
    } | ${cfg.mailScript} "Backup health alert"
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
        Also warn when a configured source backup has no snapshot within
        72 hours, or its repository cannot be inspected.
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
    assertions = mapAttrsToList (name: backup: {
      assertion = elem "--tag ${name}" backup.extraBackupArgs;
      message = "The backup freshness monitor requires restic job ${name} to use --tag ${name}.";
    }) sourceJobs;

    systemd.services.offsite-deadman = {
      description = "Warn about stale source backups or missing offsite reports";
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
