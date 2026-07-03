{
  ageSecrets,
  config,
  pkgs,
  ...
}:

{
  age.secrets.airtrail-env = ageSecrets.airtrail-env;

  virtualisation = {
    containers.enable = true;
    oci-containers = {
      backend = "podman";
      containers = {
        airtrail = {
          image = "johly/airtrail:latest";
          autoStart = true;
          environmentFiles = [ config.age.secrets.airtrail-env.path ];
          ports = [ "127.0.0.1:3000:3000" ];
          volumes = [
            "/var/lib/airtrail/uploads:/app/uploads"
          ];
          dependsOn = [ "airtrail-db" ];
          extraOptions = [
            "--network=airtrail"
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
            "--network=airtrail"
          ];
        };
      };
    };
  };

  systemd = {
    services = {
      podman-network-airtrail = {
        description = "Podman network for AirTrail";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "podman-network-airtrail-start" ''
            ${pkgs.podman}/bin/podman network exists airtrail || ${pkgs.podman}/bin/podman network create airtrail
          '';
          ExecStop = pkgs.writeShellScript "podman-network-airtrail-stop" ''
            ${pkgs.podman}/bin/podman network rm airtrail || true
          '';
        };
      };

      podman-airtrail = {
        after = [ "podman-network-airtrail.service" ];
        requires = [ "podman-network-airtrail.service" ];
      };

      podman-airtrail-db = {
        after = [ "podman-network-airtrail.service" ];
        requires = [ "podman-network-airtrail.service" ];
        preStart = ''
          set -eu
          set -a
          . ${config.age.secrets.airtrail-env.path}
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
      "d /var/lib/airtrail/postgres 0700 root root -"
      "d /var/lib/airtrail/uploads 0755 1000 1000 -"
    ];
  };

  services.nginx.virtualHosts."flights.piergabory.net" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
