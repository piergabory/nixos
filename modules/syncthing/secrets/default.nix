{
  inputs,
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.services.syncthing;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets.syncthing-gui = {
      file = ./gui.age;
      owner = "piergabory";
    };
  };
}
