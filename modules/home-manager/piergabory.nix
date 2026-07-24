{ inputs, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.default
    ./accounts
    ./programs
    ./developer
    ./xdg.nix
  ];

  config = {
    home = {
      stateVersion = "26.05";
      username = "piergabory";
      homeDirectory = "/home/piergabory";
    };

    stylix = {
      enable = true;
      autoEnable = true;
    };
  };
}
