{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.hass-container;
in
{
  config = mkIf cfg.enable {
    systemd.services.dreame-vacuum-update = {
      description = "Update the Dreame Vacuum Home Assistant integration";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "10min";
        User = "root";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/homeassistant" ];
        NoNewPrivileges = true;
      };

      script = ''
        set -euo pipefail

        config_dir=/var/lib/homeassistant
        components="$config_dir/custom_components"
        integration="$components/dreame_vacuum"

        if [ ! -f "$config_dir/.HA_VERSION" ] || [ ! -f "$integration/manifest.json" ]; then
          echo "Home Assistant config or Dreame Vacuum integration not found" >&2
          exit 1
        fi

        latest_tag="$(${pkgs.curl}/bin/curl --fail --silent --show-error --location \
          https://api.github.com/repos/Tasshack/dreame-vacuum/releases/latest \
          | ${pkgs.jq}/bin/jq --exit-status --raw-output '.tag_name | strings | select(length > 0)')"

        # Tags are interpolated into the release download URL; accept only
        # ordinary release-tag characters.
        if [[ ! "$latest_tag" =~ ^[A-Za-z0-9._-]+$ ]]; then
          echo "Unexpected Dreame Vacuum release tag: $latest_tag" >&2
          exit 1
        fi

        installed_version="$(${pkgs.jq}/bin/jq --raw-output '.version // empty' "$integration/manifest.json")"
        if [ "$installed_version" = "$latest_tag" ]; then
          echo "Dreame Vacuum is already up to date ($installed_version)"
          exit 0
        fi

        work_dir="$(${pkgs.coreutils}/bin/mktemp --directory "$components/.dreame-vacuum-update.XXXXXX")"
        previous="$work_dir/previous"
        replacement="$work_dir/replacement"
        mkdir "$replacement"

        cleanup() {
          if [ -d "$previous" ] && [ ! -e "$integration" ]; then
            mv "$previous" "$integration"
          fi
          rm -rf "$work_dir"
        }
        trap cleanup EXIT

        archive="$work_dir/dreame_vacuum.zip"
        ${pkgs.curl}/bin/curl --fail --silent --show-error --location \
          "https://github.com/Tasshack/dreame-vacuum/releases/download/$latest_tag/dreame_vacuum.zip" \
          --output "$archive"

        # Reject archive paths that could write outside the temporary directory.
        if ${pkgs.unzip}/bin/unzip -Z1 "$archive" | ${pkgs.gnugrep}/bin/grep --extended-regexp --quiet '(^/|(^|/)\.\.(/|$))'; then
          echo "Unsafe path found in Dreame Vacuum release archive" >&2
          exit 1
        fi

        ${pkgs.unzip}/bin/unzip -q "$archive" -d "$replacement"
        manifest="$replacement/manifest.json"
        if [ ! -f "$manifest" ] \
          || [ "$(${pkgs.jq}/bin/jq --raw-output '.domain // empty' "$manifest")" != "dreame_vacuum" ] \
          || [ "$(${pkgs.jq}/bin/jq --raw-output '.version // empty' "$manifest")" != "$latest_tag" ]; then
          echo "Downloaded Dreame Vacuum archive has an invalid or unexpected manifest" >&2
          exit 1
        fi

        mv "$integration" "$previous"
        mv "$replacement" "$integration"
        rm -rf "$previous"
        ${pkgs.systemd}/bin/systemctl restart podman-homeassistant.service
        echo "Updated Dreame Vacuum to $latest_tag and restarted Home Assistant"
      '';
    };

    systemd.timers.dreame-vacuum-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        RandomizedDelaySec = "1h";
        Persistent = true;
        Unit = "dreame-vacuum-update.service";
      };
    };
  };
}
