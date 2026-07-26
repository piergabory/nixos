{
  config,
  lib,
  inputs,
  ...
}:
with lib;

let
  cfg = config.services.radicale;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets.radicale-admin = {
      file = ./admin.age;
      owner = "radicale";
    };
  };
}
