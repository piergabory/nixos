{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets.syncthing-gui = {
      file = ./gui.age;
      owner = "piergabory";
  };
}
