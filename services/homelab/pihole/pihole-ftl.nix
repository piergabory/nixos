{ config, lib, ... }:
with lib;

let
  cfg = config.services.pihole;
in {
  config = mkIf cfg.enable {
    services.pihole-ftl = {
      enable = true;
      openFirewallDNS = false;
      openFirewallWebserver = false;
      queryLogDeleter.enable = true;

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
    };
  };
}
