{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/stylix.nix
    ./activation.nix
  ];

  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    # Android shares RAM with the foreground apps; never build at CPU-count
    # parallelism. These take effect after activation; bootstrap commands must
    # also pass the limits explicitly (see scripts/nix-droid-safe.py).
    max-jobs = 1
    cores = 1
    max-substitution-jobs = 1
  '';

  user = {
    userName = "piergabory";
    shell = "${pkgs.zsh}/bin/zsh";
  };

  android-integration = {
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-setup-storage.enable = true;
    termux-reload-settings.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
    xdg-open.enable = true;
  };

  home-manager = {
    config.imports = [
      ../../../home/cli.nix
      ../../../home/droid.nix
      ./opencode.nix
    ];
    backupFileExtension = "home-manager-backup";
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      osConfig = config;
      isDroid = true;
      isDarwin = false;
    };
  };
}
