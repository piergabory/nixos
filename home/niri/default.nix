{ ... }:

{
  imports = [
    ./bindings

    ./inputs.nix
    ./outputs.nix
    ./layout.nix
    ./startup.nix
    ./window-rules.nix
  ];

  programs.niri.settings = {
    animations.enable = false;
    prefer-no-csd = true;
  };
}
