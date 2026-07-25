{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets.airtrail-env.file = ./airtrail-env.age;
}
