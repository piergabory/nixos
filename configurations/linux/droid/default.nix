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

  # Workaround for https://github.com/nix-community/nix-on-droid/issues/519 —
  # the nixpkgs-built proot-static binary can crash/misbehave on some devices
  # (e.g. SIGSEGV, or spurious "setting permissions" errors during builds).
  # Keep using the known-good proot-static bundled with the app instead of
  # letting activation swap in the freshly built (broken) one.
  build.activation.zz_unfuck_proot = ''
    echo "Keeping known-good proot-static instead of the newly built one"
    cp -v /data/data/com.termux.nix/files/usr/bin/proot-static /data/data/com.termux.nix/files/usr/bin/.proot-static.new
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
