{ ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "git+https://codeberg.org/piergabory/nix-config.git";
    flags = [
      "--no-write-lock-file"
      "-L"
    ];
    dates = "03:30";
    randomizedDelaySec = "20min";
    persistent = true; # the laptop catches up after being asleep
    operation = "switch";
    allowReboot = true;
    rebootWindow = {
      lower = "03:00";
      upper = "06:00";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.auto-optimise-store = true;
}
