{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };

      users."piergabory".imports = [
        ./piergabory.nix
      ];
    };
  };
}
