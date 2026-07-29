{ config, lib, ... }:
with lib;

let
  cfg = config.services.pihole;
in {
  imports = [
    ./pihole-ftl.nix
    ./backup.nix
  ];

  options.services.pihole = {
    enable = mkEnableOption "Pi hole";
  };

  config = mkIf cfg.enable {
    networking.nameservers = [
      "127.0.0.1"
    ];

    services.resolved.enable = false;

    services.pihole-web = {
      enable = true;
      ports = [ 8080 ];
    };

    networking.firewall.interfaces.eth0 = {
      allowedTCPPorts = [ 53 8080 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
