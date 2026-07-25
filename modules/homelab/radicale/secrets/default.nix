{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets.radicale-admin = {
    file = ./radicale/admin.age;
    owner = "radicale";
  };
}
