{ config, lib, ... }:
with lib;
let
  password_path = "/var/lib/postfix/conf/sasl_passwd";
  cfg = config.services.postfix;
in {
  config = mkIf cfg.enable {
    services.postfix = {
      rootAlias = "home_lab@pierr.re";
      postmasterAlias = "home_lab@pierr.re";

      settings.main = {
        hostname = "mail.pierr.re";
        domain = "pierr.re";
        myorigin = "pierr.re";

        relayhost = [ "[smtp.mail.me.com]:587" ];
        inet_interfaces = "loopback-only";
        mydestination = "";

        smtp_sasl_auth_enable = true;
        smtp_sasl_password_maps = "hash:${password_path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_tls_security_options = "noanonymous";

        smtp_tls_security_level = "encrypt";
        smtp_tls_CAfile = "/etc/ssl/certs/ca-certificates.crt";

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

    systemd.services = {
      # Build the SASL password map from the decrypted agenix secret at runtime
      # so the app-specific password never lands in the world-readable Nix store.
      # postfix-setup already creates /var/lib/postfix/conf and postmaps mapFiles;
      # append the SASL map generation to the same oneshot.
      postfix-setup.script = mkAfter ''
        install -m 0600 -o root -g root ${config.age.secrets.icloud-smtp-relay.path} ${password_path}
        ${config.services.postfix.package}/bin/postmap hash:${password_path}
        chmod 0600 ${password_path} ${password_path}.db
      '';

      # The Cyrus SASL client library (linked into Postfix's smtp) locates its
      # mechanism plugins (PLAIN/LOGIN, required by iCloud) via SASL_PATH. Without
      # this, no client mechanism is offered, AUTH is skipped, and iCloud rejects
      # the unauthenticated relay at RCPT TO (554 5.7.1 Access denied).
      postfix.environment.SASL_PATH = "${pkgs.cyrus_sasl.out}/lib/sasl2";
    };
  };
}
