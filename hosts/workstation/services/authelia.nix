# Authelia: self-hosted SSO / OIDC provider + nginx forward-auth gateway.
#
# - Portal served at https://auth.pierr.re
# - Acts as an OIDC provider for apps that speak OIDC natively (Immich, Actual,
#   Mastodon, ...). Those clients are declared in the `authelia-oidc-clients`
#   secret (a settings fragment) so hashed client secrets never live in the Nix
#   store.
# - Exposes a reusable nginx forward-auth snippet through
#   `config.piergabory.authelia.forwardAuthConfig` for browser-only apps that
#   have no native auth (Glance, Syncthing GUI, ...).
#
# Secrets are provided by agenix and owned by the `authelia-main` service user
# (see secrets/default.nix). Never put secret values in this file.

{
  ageSecrets,
  config,
  lib,
  pkgs,
  ...
}:

let
  domain = "pierr.re";
  authHost = "auth.${domain}";

  # nginx location that queries Authelia for an auth decision. Included inside a
  # protected vhost's server block via `extraConfig`.
  #
  # Uses the AuthRequest authz implementation endpoint (/api/authz/auth-request)
  # which returns 401 on failure so nginx's auth_request module (which only
  # accepts 2xx/401/403, never 3xx) can convert it to a portal redirect.
  internalAuthLocation = ''
    set $upstream_authelia http://127.0.0.1:9092/api/authz/auth-request;

    location /internal/authelia/authz {
      internal;
      proxy_pass $upstream_authelia;

      ## Required headers for the AuthRequest implementation.
      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";

      proxy_pass_request_body off;
      proxy_redirect http:// $scheme://;
      proxy_http_version 1.1;
      client_body_buffer_size 128k;
      proxy_read_timeout 240;
      proxy_send_timeout 240;
      proxy_connect_timeout 240;
    }
  '';

  # Per-protected-location snippet: run the auth subrequest, redirect to the
  # portal on failure (401 -> 302 to Authelia's session cookie authelia_url),
  # and pass Authelia's identity headers upstream.
  forwardAuthConfig = ''
    auth_request /internal/authelia/authz;

    ## Modern redirect: Authelia returns the portal URL in the Location header;
    ## on a 401 from the authz endpoint, redirect the browser there.
    auth_request_set $redirection_url $upstream_http_location;
    error_page 401 =302 $redirection_url;

    ## Propagate identity headers from Authelia to the backend.
    auth_request_set $user  $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name  $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;
    proxy_set_header Remote-User   $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Name   $name;
    proxy_set_header Remote-Email  $email;
  '';
in
{
  options.piergabory.authelia = {
    forwardAuthConfig = lib.mkOption {
      type = lib.types.lines;
      readOnly = true;
      default = forwardAuthConfig;
      description = ''
        nginx `extraConfig` snippet to drop into a protected location to gate it
        behind Authelia forward-auth. The enclosing vhost must also include
        `config.piergabory.authelia.internalAuthLocation` in its server-level
        `extraConfig`.
      '';
    };

    internalAuthLocation = lib.mkOption {
      type = lib.types.lines;
      readOnly = true;
      default = internalAuthLocation;
      description = "Server-level nginx snippet exposing the internal Authelia authz endpoint.";
    };
  };

  config = {
    age.secrets = {
      authelia-jwt = ageSecrets.authelia-jwt;
      authelia-session = ageSecrets.authelia-session;
      authelia-storage-key = ageSecrets.authelia-storage-key;
      authelia-oidc-hmac = ageSecrets.authelia-oidc-hmac;
      authelia-oidc-jwks = ageSecrets.authelia-oidc-jwks;
      authelia-users = ageSecrets.authelia-users;
      authelia-oidc-clients = ageSecrets.authelia-oidc-clients;
    };

    services.authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = config.age.secrets.authelia-jwt.path;
        sessionSecretFile = config.age.secrets.authelia-session.path;
        storageEncryptionKeyFile = config.age.secrets.authelia-storage-key.path;
        oidcHmacSecretFile = config.age.secrets.authelia-oidc-hmac.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-jwks.path;
      };

      # Extra config fragments merged on top of `settings`. The OIDC client
      # registrations live here so their hashed secrets stay out of the Nix
      # store. (The users database is referenced via authentication_backend.file
      # rather than merged as settings.)
      #
      # NOTE: this file must contain at least one client with a valid pbkdf2
      # hash or Authelia will refuse to start.
      settingsFiles = [ config.age.secrets.authelia-oidc-clients.path ];

      settings = {
        theme = "auto";

        # Port 9092: 9091 (Authelia's default) is taken by transmission-daemon
        # from the nixarr media stack.
        server.address = "tcp://127.0.0.1:9092";

        log = {
          level = "info";
          format = "text";
        };

        # File-based user database (argon2id hashes provided via authelia-users).
        # Point directly at the agenix-decrypted path; it is owned by
        # authelia-main (mode 0400) so the sandboxed service can read it.
        authentication_backend = {
          password_reset.disable = true;
          file = {
            path = config.age.secrets.authelia-users.path;
            watch = false;
            password.algorithm = "argon2";
          };
        };

        # Brute-force protection: lock a user out after repeated failures.
        regulation = {
          max_retries = 3;
          find_time = "2m";
          ban_time = "10m";
        };

        session = {
          name = "authelia_session";
          expiration = "1h";
          inactivity = "5m";
          remember_me = "1M";
          cookies = [
            {
              domain = domain;
              authelia_url = "https://${authHost}";
              default_redirection_url = "https://${domain}";
            }
          ];
        };

        storage.local.path = "/var/lib/authelia-main/db.sqlite3";

        # Postfix accepts unauthenticated SMTP only over loopback, then relays it
        # through iCloud over TLS. TLS is therefore unnecessary on this local hop.
        notifier = {
          disable_startup_check = false;
          smtp = {
            address = "smtp://127.0.0.1:25";
            sender = "Authelia <home_lab@pierr.re>";
            startup_check_address = "home_lab@pierr.re";
            disable_require_tls = true;
            disable_starttls = true;
          };
        };

        # Default-deny. Only the subdomains actually protected by nginx
        # forward-auth need explicit rules here. OIDC clients (Immich, Actual,
        # Mastodon, ...) enforce auth through the OIDC flow, not forward-auth,
        # so they are not listed here.
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = authHost;
              policy = "bypass";
            }
            {
              domain = [
                "dash.${domain}"
                "sync.${domain}"
              ];
              policy = "two_factor";
            }
          ];
        };

        # Individual OIDC clients are declared in the authelia-oidc-clients
        # secret (loaded via settingsFiles).
        identity_providers.oidc.enable_client_debug_messages = false;
      };
    };

    services.restic.backups.authelia = {
      inherit (config.piergabory.backups) repository passwordFile pruneOpts;
      initialize = true;
      timerConfig = config.piergabory.backups.timerConfig // {
        OnCalendar = "03:10";
      };
      paths = [ "/var/backup/restic/authelia" ];
      backupPrepareCommand = ''
        rm -rf /var/backup/restic/authelia
        mkdir -p /var/backup/restic/authelia
        ${pkgs.sqlite}/bin/sqlite3 /var/lib/authelia-main/db.sqlite3 ".backup '/var/backup/restic/authelia/db.sqlite3'"
      '';
      extraBackupArgs = [
        "--tag authelia"
        "--one-file-system"
      ];
    };

    services.nginx.virtualHosts."${authHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9092";
        proxyWebsockets = true;
      };
    };
  };
}
