{ ... }:

{
  networking.nameservers = [
    "127.0.0.1"
  ];
  
  services.pihole-ftl = {
    enable = true;
    settings = {
      dns = {
        upstreams = [
          "1.1.1.1"
          "9.9.9.9"
          "8.8.8.8"
        ];
      };
    };

    openFirewallDNS = true;
    openFirewallWebserver = true;
    lists = [
      {
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
        type = "block";
        enabled = true;
        description = "hagezi blocklist";
      }
      {
        url = "https://media.githubusercontent.com/media/zachlagden/Pi-hole-Optimized-Blocklists/main/lists/all_domains.txt";
        type = "block";
        enabled = true;
        description ="zachlagden blocklist";
      }
    ];
    queryLogDeleter.enable = true;
  };

  services.pihole-web = {
    enable = true;
    ports = [ 8080 ];
    hostName = "pihole.piergabory.net";
  };

  networking.firewall = {
    allowedTCPPorts = [
      53
      8080
    ];
    allowedUDPPorts = [ 53 ];
  };

  services.nginx.virtualHosts."pihole.piergabory.net" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
    };
  };
}
