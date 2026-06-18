{
  config,
  lib,
  pkgs,
  ...
}:

let
  backupTimers = [
    "backup-vaultwarden.timer"
    "restic-backups-actual.timer"
    "restic-backups-mastodon.timer"
    "restic-backups-minecraft.timer"
    "restic-backups-radicale.timer"
    "restic-backups-vaultwarden.timer"
  ];
in

{
  systemd.services.glance.serviceConfig.ExecStartPre = lib.mkBefore [
    ''
      +/bin/sh -c 'printf "Bearer " > /run/glance/home-assistant-authorization && tr -d "\n" < ${config.age.secrets.home-assistant-token.path} >> /run/glance/home-assistant-authorization && chmod 600 /run/glance/home-assistant-authorization'
    ''
  ];

  systemd.tmpfiles.rules = [
    "d /run/glance-assets 0755 root root -"
  ];

  systemd.services.glance-systemd-status = {
    description = "Export selected systemd service statuses for Glance";
    serviceConfig.Type = "oneshot";
    path = [
      config.systemd.package
      pkgs.coreutils
      pkgs.jq
    ];
    script = ''
      output=/run/glance-assets/systemd-services.json
      tmp="$output.tmp"

      mkdir -p /run/glance-assets

      generated_at=$(date --utc --iso-8601=seconds)

      systemctl list-units --type=service --all --no-legend --plain \
        | jq --raw-input --slurp --arg generatedAt "$generated_at" '
            split("\n")
            | map(
                select(length > 0)
                | capture("^(?<id>\\S+)\\s+(?<loadState>\\S+)\\s+(?<activeState>\\S+)\\s+(?<subState>\\S+)\\s+(?<description>.*)$")
              )
            | map(select(.loadState != "not-found" and (.activeState == "active" or .activeState == "failed")))
            | sort_by(if .activeState == "failed" then 0 else 1 end, .id)
            | {
                generatedAt: $generatedAt,
                services: .
              }
          ' > "$tmp"

      mv "$tmp" "$output"
      chmod 0644 "$output"
    '';
  };

  systemd.services.glance-backup-status = {
    description = "Export backup timer statuses for Glance";
    serviceConfig.Type = "oneshot";
    path = [
      config.systemd.package
      pkgs.coreutils
      pkgs.jq
    ];
    script = ''
      output=/run/glance-assets/backup-timers.json
      tmp="$output.tmp"

      mkdir -p /run/glance-assets

      printf '{"generatedAt":%s,"timers":[' "$(date --utc --iso-8601=seconds | jq --raw-input --slurp 'rtrimstr("\n")')" > "$tmp"
      first=1
      for timer in ${builtins.concatStringsSep " " backupTimers}; do
        if [ "$first" -eq 0 ]; then
          printf ',' >> "$tmp"
        fi
        first=0

        service="''${timer%.timer}.service"
        systemctl show "$timer" \
          --property=Id \
          --property=ActiveState \
          --property=LastTriggerUSec \
          --property=NextElapseUSecRealtime \
          | jq --raw-input --slurp --arg timer "$timer" --arg service "$service" --arg serviceResult "$(systemctl show "$service" --property=Result --value)" --arg serviceState "$(systemctl show "$service" --property=ActiveState --value)" '
              split("\n") |
              map(select(length > 0) | split("=") | {(.[0]): .[1]}) |
              add as $unit |
              {
                id: ($unit.Id // $timer),
                service: $service,
                activeState: ($unit.ActiveState // "unknown"),
                lastTrigger: ($unit.LastTriggerUSec // ""),
                nextElapse: ($unit.NextElapseUSecRealtime // ""),
                serviceActiveState: $serviceState,
                serviceResult: $serviceResult
              }
            ' >> "$tmp"
      done
      printf ']}' >> "$tmp"
      mv "$tmp" "$output"
      chmod 0644 "$output"
    '';
  };

  systemd.timers.glance-systemd-status = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "5m";
      AccuracySec = "30s";
      Unit = "glance-systemd-status.service";
    };
  };

  systemd.timers.glance-backup-status = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "35s";
      OnUnitActiveSec = "5m";
      AccuracySec = "30s";
      Unit = "glance-backup-status.service";
    };
  };
}
