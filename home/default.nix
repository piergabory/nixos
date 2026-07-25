{ config, ... }:
let
  cfg = config.home;
in {
  imports = [
    ./accounts
    ./programs
    ./developer
    ./xdg.nix
  ];

  config = {
    home.stateVersion = "26.05";

    stylix = {
      enable = true;
      autoEnable = true;
    };
  };
}
