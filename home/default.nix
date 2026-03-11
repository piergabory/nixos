{ ... }:

{
  imports = [
    ./niri

    ./helix.nix
    ./config.nix
    ./mpc.nix
    ./fonts.nix
    ./git.nix
    ./graphics.nix
    ./gtk.nix
    ./packages.nix
    ./waybar.nix
    ./zen.nix
  ];

  home = {
    username = "piergabory";
    homeDirectory = "/home/piergabory";
    stateVersion = "25.11";
  };
}
