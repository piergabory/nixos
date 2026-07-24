{ inputs, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.default
    ./programs
    ./developer
  ];

  config = {
    home = {
      stateVersion = "26.05";
      username = "root";
      homeDirectory = "/root";
    };

    stylix = {
      enable = true;
      autoEnable = true;
    };
  };
}
