{ ... }:

{
  imports = [
    ./policies.nix
    ./pins.nix
    ./settings.nix
    ./extensions.nix
  ];

  programs.chromium.enable = true;
}
