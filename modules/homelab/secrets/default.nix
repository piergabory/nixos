{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets = {
    icloud-smtp-relay.file = ./icloud-smtp-relay.age;
    restic-password.file = ./restic-password.age;
  };
}
