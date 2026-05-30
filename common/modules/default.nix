{ ... }:

{
  imports = [
    ./environment.nix
    ./bluetooth.nix
    ./niri.nix
    ./shell.nix
    ./stylix.nix
    ./users.nix
    ./displaymanager.nix
    ./scanner.nix
    ./steam.nix
    ./nixvim
  ];
}
