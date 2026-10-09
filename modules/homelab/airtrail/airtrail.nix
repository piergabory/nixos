{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.services.airtrail;
in
{
  options.services.airtrail = {
    enable = mkEnableOption "Airtrail service";
    environmentFile = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.int;
      default = 3000;
    };
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      oci-containers = {
        backend = "podman";
        # These containers are members of a pod managed by separate systemd
        # units. Podman's auto-update fails to resolve those pod-member units
        # ("no PODMAN_SYSTEMD_UNIT label found"), even though the labels are
        # present. A dedicated timer below checks for image changes instead.
        containers = {
          airtrail = {
            image = "docker.io/johly/airtrail:latest";
            pull = "always";
            autoStart = true;
            environmentFiles = [ "/run/airtrail/app.env" ];
            volumes = [
              "/var/lib/airtrail/uploads:/app/uploads"
            ];
            dependsOn = [ "airtrail-db" ];
            extraOptions = [
              "--pod=airtrail"
            ];
          };

          airtrail-db = {
            image = "docker.io/library/postgres:16-alpine";
            pull = "always";
            autoStart = true;
            environmentFiles = [ "/run/airtrail/postgres.env" ];
            volumes = [
              "/var/lib/airtrail/postgres:/var/lib/postgresql/data"
            ];
            extraOptions = [
              "--pod=airtrail"
            ];
          };
        };
      };
    };

    systemd = {
      services = {
        podman-pod-airtrail = {
          description = "Podman pod for AirTrail";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "podman-pod-airtrail-start" ''
              ${pkgs.podman}/bin/podman pod exists airtrail ||\
              ${pkgs.podman}/bin/podman pod create \
                --name airtrail \
                --publish ${cfg.host}:${toString cfg.port}:3000
            '';
          };
        };

        podman-airtrail = {
          after = [ "podman-pod-airtrail.service" ];
          requires = [ "podman-pod-airtrail.service" ];
          preStart = ''
            set -eu
            set -a
            . ${cfg.environmentFile}
            set +a

            DB_DATABASE_NAME="''${DB_DATABASE_NAME:-airtrail}"
            DB_USERNAME="''${DB_USERNAME:-airtrail}"
            UPLOAD_LOCATION="''${UPLOAD_LOCATION:-/app/uploads}"

            test -n "''${ORIGIN:-}"
            test -n "''${DB_PASSWORD:-}"
            ${pkgs.coreutils}/bin/mkdir -p /run/airtrail
            umask 077
            ${pkgs.gnused}/bin/sed '/^DB_URL=/d' ${cfg.environmentFile} > /run/airtrail/app.env
            {
              printf 'DB_URL=postgres://%s:%s@${cfg.host}:5432/%s\n' "$DB_USERNAME" "$DB_PASSWORD" "$DB_DATABASE_NAME"
              printf 'UPLOAD_LOCATION=%s\n' "$UPLOAD_LOCATION"
            } >> /run/airtrail/app.env
          '';
        };

        podman-airtrail-db = {
          after = [ "podman-pod-airtrail.service" ];
          requires = [ "podman-pod-airtrail.service" ];
          preStart = ''
            set -eu
            set -a
            . ${cfg.environmentFile}
            set +a

            DB_DATABASE_NAME="''${DB_DATABASE_NAME:-airtrail}"
            DB_USERNAME="''${DB_USERNAME:-airtrail}"

            test -n "''${DB_PASSWORD:-}"
            ${pkgs.coreutils}/bin/mkdir -p /run/airtrail
            umask 077
            {
              printf 'POSTGRES_DB=%s\n' "$DB_DATABASE_NAME"
              printf 'POSTGRES_USER=%s\n' "$DB_USERNAME"
              printf 'POSTGRES_PASSWORD=%s\n' "$DB_PASSWORD"
          } > /run/airtrail/postgres.env
          '';
        };

        airtrail-image-update = {
          description = "Check for and apply AirTrail container image updates";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            set -eu
            podman=${pkgs.podman}/bin/podman
            systemctl=${pkgs.systemd}/bin/systemctl

            # Pull both images before restarting anything, so a registry failure
            # leaves the currently running AirTrail pod untouched.
            "$podman" pull docker.io/library/postgres:16-alpine
            "$podman" pull docker.io/johly/airtrail:latest

            current_db="$($podman inspect --format '{{.Image}}' airtrail-db)"
            latest_db="$($podman image inspect --format '{{.Id}}' docker.io/library/postgres:16-alpine)"
            current_app="$($podman inspect --format '{{.Image}}' airtrail)"
            latest_app="$($podman image inspect --format '{{.Id}}' docker.io/johly/airtrail:latest)"

            if [ "$current_db" != "$latest_db" ]; then
              echo "PostgreSQL image update found; restarting database"
              "$systemctl" restart podman-airtrail-db.service

              ready=false
              for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
                if "$podman" exec airtrail-db pg_isready -q >/dev/null 2>&1; then
                  ready=true
                  break
                fi
                ${pkgs.coreutils}/bin/sleep 2
              done
              if [ "$ready" != true ]; then
                echo "AirTrail database did not become ready within 120 seconds" >&2
                exit 1
              fi
            fi

            if [ "$current_db" != "$latest_db" ] || [ "$current_app" != "$latest_app" ]; then
              echo "AirTrail image update found; restarting application"
              "$systemctl" restart podman-airtrail.service
            else
              echo "AirTrail images are already current"
            fi
          '';
        };
      };

      tmpfiles.rules = [
        "d /var/lib/airtrail/postgres 0700 70 root -"
        "d /var/lib/airtrail/uploads 0755 1000 1000 -"
      ];

      timers.airtrail-image-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Sun *-*-* 04:00:00";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
  };
}
