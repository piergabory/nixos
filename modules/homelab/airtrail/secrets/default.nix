{
  inputs,
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.services.airtrail;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets.airtrail-env.file = ./airtrail-env.age;
  };
}
