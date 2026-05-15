{ config, pkgs, ... }:

{
  age.secrets.radicale = {
    file = ../../../secrets/radicale.age;
    mode = "0644";
  };

  services.radicale = {
    enable = true;
    settings = {
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale.path;
        htpasswd_encryption = "plain";
      };
      server.hosts = [ "127.0.0.1:5232" ];
    };
  };

  services.restic.backups.radicale = {
    inherit (config.piergabory.backups) repository passwordFile pruneOpts;
    initialize = true;
    timerConfig = config.piergabory.backups.timerConfig // {
      OnCalendar = "03:30";
    };
    paths = [
      "/var/lib/radicale/collections"
    ];
    extraBackupArgs = [
      "--tag radicale"
      "--one-file-system"
    ];
  };

  services.nginx.virtualHosts."dav.piergabory.net" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5232";
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Script-Name /radicale;
        proxy_pass_header Authorization;
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    apacheHttpd
  ];
}
