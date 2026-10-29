{ pkgs, ... }:

{
  imports = [
    ./developer/git.nix
    ./developer/nixvim
    ./programs/ssh.nix
  ];

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      ragenix
      yazi
    ];
  };

  programs = {
    btop.enable = true;
    zellij.enable = true;
  };

  stylix = {
    enable = true;
    autoEnable = true;
  };
}
