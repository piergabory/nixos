{ inputs, pkgs, ... }:

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

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs;
    };
    users.pgabory = {
      imports = [
        inputs.agenix.homeManagerModules.default
        # ./accounts TODO FIXME
        ../../modules/home-manager/programs
        ../../modules/home-manager/developer
      ];

      home = {
        username = "pgabory";
        homeDirectory = "/Users/pgabory";
        stateVersion = "26.05"; # Please read the comment before changing.
      };
    };
  };
}
