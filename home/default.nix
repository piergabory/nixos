{
  imports = [
    ./accounts
    ./programs
    ./developer
    ./music.nix
    ./xdg.nix
  ];

  config = {
    home.stateVersion = "26.05";

    musicLibrary.enable = true;

    stylix = {
      enable = true;
      autoEnable = true;
    };
  };
}
