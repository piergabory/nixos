{
  lib,
  isDroid ? false,
  ...
}:

{
  imports = [
    ./developer
  ]
  ++ lib.optionals isDroid [
    ./droid.nix
  ]
  ++ lib.optionals (!isDroid) [
    ./accounts
    ./programs
    ./music.nix
    ./xdg.nix
  ];

  config = {
    home.stateVersion = "26.05";

    stylix = {
      enable = true;
      autoEnable = !isDroid;
      targets.wayprompt.enable = false;
    };
  }
  // lib.optionalAttrs (!isDroid) {
    musicLibrary.enable = true;
  };
}
