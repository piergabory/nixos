{ ... }:

{
  imports = [
    ./niri

    ./config.nix
    ./fonts.nix
    ./git.nix
    ./graphics.nix
    ./gtk.nix
    ./packages.nix
    ./zen.nix
  ];

  home = {
    username = "piergabory";
    homeDirectory = "/home/piergabory";
    stateVersion = "25.11";
  };
}
