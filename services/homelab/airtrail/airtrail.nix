{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.airtrail;
in {
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
        containers = {
          airtrail = {
            image = "johly/airtrail:latest";
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
            image = "postgres:16-alpine";
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
      };

      tmpfiles.rules = [
        "d /var/lib/airtrail/postgres 0700 70 root -"
        "d /var/lib/airtrail/uploads 0755 1000 1000 -"
      ];
    };
  };
}
