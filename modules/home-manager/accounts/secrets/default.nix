{ inputs, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  config.age.secrets.radicale-dav.file = ./dav.age;
}
