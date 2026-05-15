{ ... }:

{
  imports = [
    ../../modules
    ../../services
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  nix.settings.trusted-users = [
    "root"
    "piergabory"
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    channel = "https://channels.nixos.org/nixos-unstable";
  };
}
