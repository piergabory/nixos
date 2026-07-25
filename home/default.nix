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
    home = {
      stateVersion = "26.05";
      homeDirectory = (
        if cfg.username == "root"
        then "/root"
        else "/home/${cfg.username}"
      );
    };

    stylix = {
      enable = true;
      autoEnable = true;
    };
  };
}
