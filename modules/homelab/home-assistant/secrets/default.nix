{
  inputs,
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.services.hass-container;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets.home-assistant-token.file = ./home-assistant-token.age;
  };
}
