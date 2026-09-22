{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/stylix.nix
  ];

  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
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
    config = ../../../home;
    backupFileExtension = "home-manager-backup";
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      osConfig = config;
      isDroid = true;
    };
  };
}
