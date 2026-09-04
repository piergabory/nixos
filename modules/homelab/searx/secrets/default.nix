{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.searx;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets.searx-env = {
      file = ./searx-env.age;
      owner = "searx";
    };
  };
}
