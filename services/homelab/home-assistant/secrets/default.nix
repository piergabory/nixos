{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config.age.secrets.home-assistant-token.file = ./home-assistant-token.age;
}
