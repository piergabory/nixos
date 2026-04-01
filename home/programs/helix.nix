{ lib, ... }:

{
  programs.helix = {
    enable = true;

    settings.theme = lib.mkForce "gruvbox_dark_hard";

    languages.language = [
      {
        name = "rust";
        formatter = { command = "rustfmt"; args = ["--edition" "2021"]; };
      }
    ];
  };
}
