{ config, lib, ... }:
with lib;

let
  cfg = config.services.openssh;
in
{
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

    # Pinned centrally so no machine ever has to answer a host key prompt, and
    # so a first connection cannot be silently intercepted. "offsite.pierr.re"
    # is a HostKeyAlias rather than a real name: the offsite machine is reached
    # through a reverse tunnel and has no address of its own.
    programs.ssh.knownHosts = {
      "workstation" = {
        hostNames = [
          "workstation"
          "pierr.re"
          "192.168.1.4"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM";
      };

      "offsite" = {
        hostNames = [
          "offsite"
          "offsite.pierr.re"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHf8xIos3OZiw/V7IwItIbskxTCRh2t+fD0Stc9SG5n";
      };
    };

    mainUser.userConfiguration.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeVLwNdm/0gW57vMU2IUdxAyU/u5kDZAhbsUdw8Zzo/ piergabory@offsite"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAS22PG/XhizL2cKiWrofCG0YHltXgjz6gFJTzvyt1xo piergabory@workstation"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5tBVh+IFkng8sPxKroP3EZ9LfIC+Q2A9W8wOnDKJUV piergabory@thinkpad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFsc6h97lG4SHJTnmUzbmcbaIXU8O/NstwxP6WkvC+G pgabory@FR318LM015.local"
    ];
  };
}
