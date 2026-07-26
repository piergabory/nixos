{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets.radicale-admin = {
    file = ./admin.age;
    owner = "radicale";
  };
}
