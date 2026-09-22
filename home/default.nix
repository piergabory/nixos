{ lib, isDroid ? false, ... }:

{
  imports =
    [
      ./developer
    ]
    ++ lib.optionals (!isDroid) [
      ./accounts
      ./programs
      ./music.nix
      ./xdg.nix
    ];

  config =
    {
      home.stateVersion = "26.05";

      stylix = {
        enable = true;
        autoEnable = !isDroid;
      };
    }
    // lib.optionalAttrs (!isDroid) {
      musicLibrary.enable = true;
    };
}
