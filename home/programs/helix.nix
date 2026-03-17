{ lib, ... }:

{
  programs.helix = {
    enable = true;

    settings.theme = lib.mkForce "gruvbox_dark_hard";
  };
}
