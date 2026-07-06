{
  ageSecrets,
  config,
  lib,
  pkgs,
  ...
}:

let
  # Root-owned agenix secret containing a single Postfix SASL map line:
  #   smtp.mail.me.com:587 piergabory@icloud.com:<app-specific-password>
  saslSecret = config.age.secrets.icloud-smtp-relay.path;
  saslPasswd = "/var/lib/postfix/conf/sasl_passwd";
in
{
  age.secrets.icloud-smtp-relay = ageSecrets.icloud-smtp-relay;

  services.postfix = {
    enable = true;

    # System/RAID/cron mail addressed to root goes to a real iCloud
    # custom-domain alias so alerts actually reach an inbox.
    rootAlias = "home_lab@pierr.re";
    postmasterAlias = "home_lab@pierr.re";

    settings.main = {
      hostname = "mail.pierr.re";
      domain = "pierr.re";
      # Present the custom domain as the envelope origin for locally
      # generated mail (e.g. root@); Apple accepts pierr.re as it is a
      # verified iCloud custom email domain.
      myorigin = "pierr.re";

      # Relay all outbound mail through the authenticated iCloud smarthost.
      # Direct-to-MX delivery is impossible from this residential IP (only
      # 80/443/22 are forwarded and port 25 egress is blocked), so every
      # message is submitted to smtp.mail.me.com over TLS on port 587.
      # Angled brackets disable MX/SRV lookups for the smarthost.
      relayhost = [ "[smtp.mail.me.com]:587" ];

      # Null client: only accept mail from the local host over loopback.
      # Nothing on the network should reach Postfix; local apps connect to
      # 127.0.0.1:25. This also keeps port 25 closed to the outside.
      inet_interfaces = "loopback-only";
      mydestination = "";

      # SASL authentication to the iCloud submission service.
      smtp_sasl_auth_enable = true;
      smtp_sasl_password_maps = "hash:${saslPasswd}";
      # iCloud offers LOGIN/PLAIN, which Postfix refuses by default
      # (noplaintext). Allow them; confidentiality is provided by TLS below.
      smtp_sasl_security_options = "noanonymous";
      smtp_sasl_tls_security_options = "noanonymous";

      # Submission on 587 requires TLS.
      smtp_tls_security_level = "encrypt";
      smtp_tls_CAfile = "/etc/ssl/certs/ca-certificates.crt";

      # Postfix strips environment variables not listed here before spawning
      # child processes, so SASL_PATH (set on the service, pointing at the
      # Cyrus client mechanism plugins) must be whitelisted or the smtp client
      # cannot find PLAIN/LOGIN and AUTH is silently skipped. The rest are the
      # Postfix defaults, preserved.
      import_environment = [
        "MAIL_CONFIG"
        "MAIL_DEBUG"
        "MAIL_LOGTAG"
        "TZ"
        "XAUTHORITY"
        "DISPLAY"
        "LANG=C"
        "POSTLOG_SERVICE"
        "POSTLOG_HOSTNAME"
        "XDG_RUNTIME_DIR"
        "SASL_PATH"
      ];
    };
  };

  # Build the SASL password map from the decrypted agenix secret at runtime
  # so the app-specific password never lands in the world-readable Nix store.
  # postfix-setup already creates /var/lib/postfix/conf and postmaps mapFiles;
  # append the SASL map generation to the same oneshot.
  systemd.services.postfix-setup.script = lib.mkAfter ''
    install -m 0600 -o root -g root ${saslSecret} ${saslPasswd}
    ${config.services.postfix.package}/bin/postmap hash:${saslPasswd}
    chmod 0600 ${saslPasswd} ${saslPasswd}.db
  '';

  # The Cyrus SASL client library (linked into Postfix's smtp) locates its
  # mechanism plugins (PLAIN/LOGIN, required by iCloud) via SASL_PATH. Without
  # this, no client mechanism is offered, AUTH is skipped, and iCloud rejects
  # the unauthenticated relay at RCPT TO (554 5.7.1 Access denied).
  systemd.services.postfix.environment.SASL_PATH = "${pkgs.cyrus_sasl.out}/lib/sasl2";
}
