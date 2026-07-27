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
      AllowUsers = [ config.mainUser.username ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    mainUser.userConfiguration.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAS22PG/XhizL2cKiWrofCG0YHltXgjz6gFJTzvyt1xo piergabory@workstation"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5tBVh+IFkng8sPxKroP3EZ9LfIC+Q2A9W8wOnDKJUV piergabory@thinkpad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFsc6h97lG4SHJTnmUzbmcbaIXU8O/NstwxP6WkvC+G pgabory@FR318LM015.local"
    ];
  };
}
