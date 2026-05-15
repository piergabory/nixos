# NGINX Web server with Let's Encrypt SSL/TLS

{ ... }:
{
  # ACME (Let's Encrypt) configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "mail@piergabory.net";
  };

  services.nginx = {
    enable = true;

    # Recommended settings for security and performance
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."piergabory.net" = {
      root = "/var/http/html";
      default = true;
      serverAliases = [ "www.piergabory.net" ];
      forceSSL = true;
      enableACME = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/http/html 0755 piergabory nginx -"
  ];
}
