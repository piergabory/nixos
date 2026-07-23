{ config, lib, ... }:
with lib;

let
  cfg = config.services.openssh;
in {
  config = mkIf cfg.enable {
    services.openssh.settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "piergabory" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
