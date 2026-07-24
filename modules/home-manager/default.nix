{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "home-manager-backup";
      extraSpecialArgs = { inherit inputs; };

      users."piergabory".imports = [
        ./piergabory.nix
      ];

      users."root".imports = [
        ./root.nix
      ];
    };
  };
}
