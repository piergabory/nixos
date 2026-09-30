{ config, lib, ... }:
with lib;

let
  cfg = config.services.pihole;
in {
  config = mkIf cfg.enable {
    # pihole-ftl 6.7.1 fails to build with newer GCC: `sanitize_dns_hosts` in
    # src/config/validator.c declares `int i = 0;` to walk the dns.hosts JSON
    # array but never reads it back (the index used to be reported in error
    # messages; this function doesn't return one). Since FTL's CMakeLists.txt
    # unconditionally adds -Werror to its warning flags, GCC's
    # -Wunused-but-set-variable (implied by -Wextra) turns this dead variable
    # into a hard build failure. Drop the unused counter until upstream fixes
    # it: https://github.com/pi-hole/FTL/blob/v6.7.1/src/config/validator.c
    nixpkgs.overlays = [
      (_final: prev: {
        pihole-ftl = prev.pihole-ftl.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace src/config/validator.c \
              --replace-fail 'int i = 0;
	for(cJSON *item = val->json != NULL ? val->json->child : NULL; item != NULL; item = item->next, i++)
	{

		// Check if it'"'"'s a string
		if(!cJSON_IsString(item))
			continue;' \
              'for(cJSON *item = val->json != NULL ? val->json->child : NULL; item != NULL; item = item->next)
	{

		// Check if it'"'"'s a string
		if(!cJSON_IsString(item))
			continue;'
          '';
        });
      })
    ];

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
