{
  imports = [
    ../nix.nix
    ../../modules/stylix.nix
    ../../modules/home-manager.nix
    ../../modules/pierre.nix
  ];

  system.stateVersion = 7;
}
