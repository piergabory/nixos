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
  ...
}:

let
  domain = "pierr.re";
  authHost = "auth.${domain}";

  # nginx location that queries Authelia for an auth decision. Included inside a
  # protected vhost's server block via `extraConfig`.
  #
  # Reference: Authelia "Forward Auth" integration for nginx.
  internalAuthLocation = ''
    set $upstream_authelia http://127.0.0.1:9091/api/authz/forward-auth;

    location /internal/authelia/authz {
      internal;
      proxy_pass $upstream_authelia;

      proxy_pass_request_body off;
      proxy_set_header Content-Length "";

      # Forward the original request context so Authelia can evaluate policy.
      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $http_host;
      proxy_set_header X-Forwarded-Uri $request_uri;

      client_body_buffer_size 128k;
      proxy_ssl_server_name on;
      proxy_http_version 1.1;
      proxy_read_timeout 240;
    }
  '';

  # Per-protected-location snippet: run the auth subrequest, redirect to the
  # portal on failure, and pass Authelia's identity headers upstream.
  forwardAuthConfig = ''
    auth_request /internal/authelia/authz;

    # On auth failure Authelia returns a redirect to the portal via this header.
    auth_request_set $redirect $upstream_http_location;
    error_page 401 =302 $redirect;

    # Propagate identity headers from Authelia to the backend.
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
      settingsFiles = [
        config.age.secrets.authelia-oidc-clients.path
      ];

      settings = {
        theme = "auto";

        server.address = "tcp://127.0.0.1:9091";

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

        # Start with the filesystem notifier so account/reset notifications don't
        # depend on mail delivery. Switch to the local Postfix SMTP notifier later
        # if desired.
        notifier = {
          disable_startup_check = false;
          filesystem.filename = "/var/lib/authelia-main/notification.txt";
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

        identity_providers.oidc = {
          # Individual clients are declared in the authelia-oidc-clients secret.
          enable_client_debug_messages = false;
        };
      };
    };

    services.nginx.virtualHosts."${authHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9091";
        proxyWebsockets = true;
      };
    };
  };
}
