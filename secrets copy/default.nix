{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets = {
    syncthing-api = {
      file = ./syncthing/api.age;
      owner = "piergabory";
    };
  };
}
