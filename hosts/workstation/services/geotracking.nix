{ ... }:

{
  services.dawarich = {
    enable = true;
    localDomain = "geo.pierr.re";
    webPort = 64645;
  };

  services.nginx.virtualHosts."geo.pierr.re" = {
    serverAliases = [ "geo.piergabory.net" ];
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:64645";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 2048M;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
