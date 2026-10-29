{
  config,
  inputs,
  lib,
  isDarwin,
  isDroid,
  ...
}:
with lib;
let
  cfg = config.mainUser;
in
{
  imports = [
    (
      if isDarwin then
        inputs.home-manager.darwinModules.home-manager
      else
        inputs.home-manager.nixosModules.home-manager
    )
  ];

  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = { inherit inputs isDroid isDarwin; };

    users = {
      "${cfg.username}" = {
        imports = cfg.homeConfiguration.imports ++ [ ../../home ];
        home = {
          username = cfg.username;
          homeDirectory = cfg.homeDirectory;
        };
      };

      root = mkIf (!isDarwin) {
        imports = [ ../../home/root.nix ];
        home = {
          username = "root";
          homeDirectory = "/root";
        };
      };
    };
  };
}
