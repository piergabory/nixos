{ pkgs, ... }:

{
  environment = {
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
      GIT_EDITOR = "hx";
    };

    systemPackages = with pkgs; [
      git
      nano
      helix # command is hx
      mdadm
      pciutils
      clinfo
      mesa-demos
      agenix-cli
    ];
  };
}
