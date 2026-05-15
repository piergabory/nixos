{ config, ... }:

{
  services.nginx.virtualHosts."dash.piergabory.net" = {
    forceSSL = true;
    enableACME = true;
    basicAuthFile = config.age.secrets.dash.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5678";
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass_header Authorization;
      '';
    };
  };
}
