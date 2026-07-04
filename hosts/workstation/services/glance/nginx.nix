{ config, ... }:

{
  services.nginx.virtualHosts."dash.pierr.re" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = config.piergabory.authelia.internalAuthLocation;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5678";
      extraConfig = ''
        ${config.piergabory.authelia.forwardAuthConfig}
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
