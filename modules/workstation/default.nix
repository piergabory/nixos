{ ... }:

{
  imports = [
    ./boot.nix
    ./localisation.nix
    ./networking.nix
    ../displaymanager.nix
    ../flatpak.nix
    ../graphics-card.nix
    ../scanner.nix
    ../steam.nix
    ../swap.nix
  ];
}
