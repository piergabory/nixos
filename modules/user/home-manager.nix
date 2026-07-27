{
  config,
  inputs,
  lib,
  isDarwin,
  ...
}:
with lib;
let
  cfg = config.mainUser;
  homeCfg = cfg.homeConfiguration // {
    imports = (cfg.homeConfiguration.imports or []) ++ [ ../../home ];
  };
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
    extraSpecialArgs = { inherit inputs; };

    users = {
      "${cfg.username}" = {
        home = {
          username = cfg.username;
          homeDirectory = cfg.homeDirectory;
        };
      }
      // homeCfg;

      root = mkIf (isDarwin == false) (
        {
          home = {
            username = "root";
            homeDirectory = "/root";
          };
        }
        // homeCfg
      );
    };
  };
}
