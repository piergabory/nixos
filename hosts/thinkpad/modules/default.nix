{ ... }:

{
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ../../../common/modules/displaymanager.nix
    ./localisation.nix
    ./networking.nix
    ../../../common/modules/scanner.nix
    ../../../common/modules/steam.nix
  ];
}
