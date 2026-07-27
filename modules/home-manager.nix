{ inputs, config, lib, useDarwinModule, ... }:
with lib;

let
  cfg = config.home-manager;
in {
  imports = [
    (
	if useDarwinModule
	then inputs.home-manager.darwinModules.home-manager
	else inputs.home-manager.nixosModules.home-manager
)
];

  options.home-manager = with types; {
    managed-users = mkOption {
      type = listOf str;
      default = [];
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "home-manager-backup";
      extraSpecialArgs = { inherit inputs; };

      users = mkMerge (map (username: {
        "${username}" = {
          home = { inherit username; };
          imports = [ ../home ];
        };
      }) cfg.managed-users);
    };
  };
}
