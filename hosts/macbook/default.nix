{ inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../modules/stylix.nix
  ];

  system.stateVersion = 7;

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  pierre = {
    enable = true;
    username = "pgabory";
    home = "/Users/pgabory";
  };
}
