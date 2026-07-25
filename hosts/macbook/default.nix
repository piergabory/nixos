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

  users.users.pgabory = {
    name = "pgabory";
    home = "/Users/pgabory";
  };

  home-manager.managed-users = [ "pgabory" ];
}
