{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      # The offsite backup machine lives behind somebody else's router, so it
      # has no reachable address of its own. It holds a reverse tunnel open to
      # the home-lab instead; hopping through it makes the machine addressable
      # by name from anywhere, regardless of which network it currently sits on.
      #
      #     ssh piergabory@offsite.pierr.re
      #     ssh offsite
      #
      # Note that "offsite.pierr.re" is never actually resolved: this block
      # matches first and rewrites the connection to the tunnel endpoint.
      "offsite offsite.pierr.re" = {
        HostName = "localhost";
        Port = 2222;
        User = "piergabory";
        ProxyJump = "piergabory@pierr.re";
        # The far end of the tunnel is a different machine than the jump host,
        # but both are reached as "localhost". Pinning the identity to a stable
        # alias keeps the two from colliding in known_hosts.
        HostKeyAlias = "offsite.pierr.re";
      };

      "workstation" = {
        HostName = "pierr.re";
        User = "piergabory";
      };
    };
  };
}
