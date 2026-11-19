{ config, lib, pkgs, ... }:

let
  domain = "icloud-jmap.${config.modules.homelab.domain}";
  port = 3004;
  dataDir = "/var/lib/bulwark-legacy-proxy";
  secretsDir = "/var/lib/bulwark-legacy-proxy-secrets";
  environmentFile = "${secretsDir}/proxy.env";
  providers = (pkgs.formats.json { }).generate "icloud-providers.json" {
    icloud = {
      imap = {
        host = "imap.mail.me.com";
        port = 993;
        secure = true;
      };
      smtp = {
        host = "smtp.mail.me.com";
        port = 587;
        starttls = true;
      };
      sieve = null;
      carddav = null;
      auth.mech = [ "PLAIN" "LOGIN" ];
    };
  };
in
{
  config = lib.mkIf config.services.bulwark-lite.enable {
    virtualisation = {
      containers.enable = true;
      oci-containers = {
        backend = "podman";
        containers.bulwark-legacy-proxy = {
          image = "ghcr.io/bulwarkmail/legacy-proxy:1.0.0";
          ports = [ "127.0.0.1:${toString port}:8080" ];
          user = "100:101";
          environment = {
            PORT = "8080";
            DATA_DIR = "/data";
            PUBLIC_URL = "https://${domain}";
            DEFAULT_PROVIDER = "icloud";
            PROVIDERS_FILE = "/etc/legacy-proxy/providers.json";
            TRUST_PROXY = "10.88.0.1";
            NODE_OPTIONS = "--require=/etc/legacy-proxy/icloud-compat.cjs";
          };
          environmentFiles = [ environmentFile ];
          volumes = [
            "${dataDir}:/data"
            "${providers}:/etc/legacy-proxy/providers.json:ro"
            "${./icloud-compat.cjs}:/etc/legacy-proxy/icloud-compat.cjs:ro"
          ];
          extraOptions = [
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
          ];
        };
      };
    };

    # UID/GID of the unprivileged proxy user in the pinned upstream image.
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0700 100 101 -"
    ];

    systemd.services = {
      bulwark-legacy-proxy-secrets = {
        description = "Create persistent encryption keys for the iCloud JMAP bridge";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StateDirectory = "bulwark-legacy-proxy-secrets";
          StateDirectoryMode = "0700";
          UMask = "0077";
        };
        script = ''
          set -eu
          if [ ! -e ${environmentFile} ]; then
            if [ -e ${dataDir}/proxy.db ]; then
              echo "Refusing to replace missing vault keys for an existing bridge database" >&2
              exit 1
            fi
            temporary=$(${pkgs.coreutils}/bin/mktemp ${secretsDir}/proxy.env.XXXXXX)
            trap '${pkgs.coreutils}/bin/rm -f "$temporary"' EXIT
            {
              printf 'VAULT_KEY=%s\n' "$(${pkgs.openssl}/bin/openssl rand -base64 32)"
              printf 'SESSION_HMAC_KEY=%s\n' "$(${pkgs.openssl}/bin/openssl rand -base64 32)"
            } > "$temporary"
            ${pkgs.coreutils}/bin/mv "$temporary" ${environmentFile}
          fi
        '';
      };

      podman-bulwark-legacy-proxy = {
        requires = [ "bulwark-legacy-proxy-secrets.service" ];
        after = [ "bulwark-legacy-proxy-secrets.service" ];
      };
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50m;
          proxy_buffering off;
          proxy_read_timeout 1h;
        '';
      };
    };
  };
}
