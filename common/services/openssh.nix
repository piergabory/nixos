{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "piergabory" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  users.users.piergabory.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5tBVh+IFkng8sPxKroP3EZ9LfIC+Q2A9W8wOnDKJUV piergabory@thinkpad"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFsc6h97lG4SHJTnmUzbmcbaIXU8O/NstwxP6WkvC+G pgabory@FR318LM015.local"
  ];
}
