# Photo gallery service

{ pkgs, ... }:

{
  services.immich = {
    enable = true;
    port = 2283;
    host = "127.0.0.1";
    mediaLocation = "/storage/immich";
    environment = {
      IMMICH_URL = "https://photo.piergabory.net";
      # Force Immich to use integrated GPU (GPU 1) instead of discrete GPU (GPU 0)
      # HIP_VISIBLE_DEVICES accepts device index (0, 1, 2, etc) or "all"
      HIP_VISIBLE_DEVICES = "1";
    };
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  systemd = {
    services.immich-server.serviceConfig.ExecStartPre = [
      "+${pkgs.coreutils}/bin/chmod o+x /storage"
    ];
    tmpfiles.rules = [
      "d /storage/immich 0750 immich immich -"
    ];
  };
  
  environment.systemPackages = with pkgs; [
    immich-cli    
  ];

  services.nginx.virtualHosts."photo.piergabory.net" = {
    serverAliases = [ "photos.piergabory.net" "photography.piergabory.net" ];
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2283";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
