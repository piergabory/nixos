{ ... }:

{
  imports = [
    ./niri

    ./helix.nix
    ./kitty.nix
    ./config.nix
    ./mpd.nix
    ./fonts.nix
    ./git.nix
    ./graphics.nix
    ./gtk.nix
    ./packages.nix
    ./waybar.nix
    ./zen.nix
    ./transmission.nix
  ];

  home = {
    username = "piergabory";
    homeDirectory = "/home/piergabory";
    stateVersion = "25.11";
  };
}
