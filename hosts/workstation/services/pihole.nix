{ ... }:

{
  networking.nameservers = [
    "127.0.0.1"
  ];

  services.pihole-ftl = {
    enable = true;
    settings = {
      dns = {
        rateLimit = {
          count = 1000000;
          interval = 10;
        };
        upstreams = [
          "1.1.1.1"
          "1.0.0.1"
          "9.9.9.9"
          "9.9.9.10"
          "9.9.9.11"
          "149.112.112.112"
          "149.112.112.10"
          "149.112.112.11"
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
      misc.dnsmasq_lines = [
        "address=/piergabory.net/192.168.1.4"
        "address=/pierr.re/192.168.1.4"
      ];
    };

    openFirewallDNS = false;
    openFirewallWebserver = false;
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
        description = "zachlagden blocklist";
      }
    ];
    queryLogDeleter.enable = true;
  };

  services.pihole-web = {
    enable = true;
    ports = [ 8080 ];
    hostName = "pihole.piergabory.net";
  };

  networking.firewall.interfaces.eth0 = {
    allowedTCPPorts = [
      53
      8080
    ];
    allowedUDPPorts = [ 53 ];
  };

  # DANGER! This exposes pihole to the public!!
  # services.nginx.virtualHosts."pihole.piergabory.net" = {
  #   forceSSL = true;
  #   enableACME = true;
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:8080";
  #     proxyWebsockets = true;
  #   };
  # };
}
