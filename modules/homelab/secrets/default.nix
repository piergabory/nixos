{
  config,
  lib,
  inputs,
  ...
}:
with lib;

let
  cfg = config.modules.homelab;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets = {
      icloud-smtp-relay.file = ./icloud-smtp-relay.age;
      restic-password.file = ./restic-password.age;
    };
  };
}
