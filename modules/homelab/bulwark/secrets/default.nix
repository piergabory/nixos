{
  config,
  lib,
  inputs,
  ...
}:
with lib;

let
  cfg = config.services.stalwart;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets.stalwart-admin = {
      file = ./stalwart-admin.age;
      owner = cfg.user;
    };
  };
}
