{
  config,
  lib,
  pkgs,
  ...
}:

let
  systemdStatusUnits = [
    "actual.service"
    "avahi-daemon.service"
    "glance.service"
    "home-assistant-matter-hub.service"
    "home-assistant.service"
    "immich-machine-learning.service"
    "immich-server.service"
    "jellyfin.service"
    "mastodon-sidekiq-all.service"
    "mastodon-streaming-1.service"
    "mastodon-web.service"
    "matter-server.service"
    "mdmonitor.service"
    "minecraft-server.service"
    "nginx.service"
    "pihole-ftl.service"
    "postfix.service"
    "postgresql.service"
    "radicale.service"
    "redis-immich.service"
    "redis-mastodon.service"
    "samba-nmbd.service"
    "samba-smbd.service"
    "samba-wsdd.service"
    "sshd.service"
    "syncthing.service"
    "vaultwarden.service"
  ];

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

      printf '{"generatedAt":%s,"services":[' "$(date --utc --iso-8601=seconds | jq --raw-input --slurp 'rtrimstr("\n")')" > "$tmp"
      first=1
      for unit in ${builtins.concatStringsSep " " systemdStatusUnits}; do
        if [ "$first" -eq 0 ]; then
          printf ',' >> "$tmp"
        fi
        first=0

        systemctl show "$unit" \
          --property=Id \
          --property=Description \
          --property=LoadState \
          --property=ActiveState \
          --property=SubState \
          --value \
          | jq --raw-input --slurp --arg unit "$unit" '
              split("\n") as $lines |
              {
                id: ($lines[0] // $unit),
                description: ($lines[1] // ""),
                loadState: ($lines[2] // "unknown"),
                activeState: ($lines[3] // "unknown"),
                subState: ($lines[4] // "unknown")
              }
            ' >> "$tmp"
      done
      printf ']}' >> "$tmp"
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
