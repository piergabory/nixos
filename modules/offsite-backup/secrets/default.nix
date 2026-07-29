{
  config,
  lib,
  inputs,
  ...
}:
with lib;

let
  cfg = config.modules.offsiteBackup;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets = {
      # Shared with the home-lab: the replica and the source use the same
      # repository password, so restic copy needs no second credential.
      restic-password.file = ../../homelab/secrets/restic-password.age;

      offsite-pull-key = {
        file = ./offsite-pull-key.age;
        mode = "0400";
        owner = "root";
      };
    }
    // optionalAttrs cfg.healthcheck.enable {
      offsite-healthcheck-url.file = ./offsite-healthcheck-url.age;
    };
  };
}
