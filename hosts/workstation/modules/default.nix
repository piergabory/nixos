{ ... }:

{
  imports = [
    ./boot.nix
    ./localisation.nix
    ./networking.nix
    ../../../common/modules/displaymanager.nix
    ./graphics-card.nix
    ../../../common/modules/scanner.nix
    ../../../common/modules/steam.nix
    ./swap.nix
  ];
}
