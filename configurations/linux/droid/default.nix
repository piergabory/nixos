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

  # Nix-on-Droid stages a new `proot-static` in `installProotStatic`, which runs
  # *after* `installPackages`. glibc >= 2.42 (Nixpkgs >= 26.05) needs the
  # 2026-02-20 proot: the older one makes `tcgetattr` fail, so `nix-env` dies
  # with "getting pseudoterminal attributes: Permission denied" and activation
  # aborts before the new proot is ever staged.
  #
  # Staging it from `activationBefore` breaks that deadlock: the binary is put
  # in place even when a later activation step fails, so closing every terminal
  # session once is enough for the login script to pick it up.
  #
  # See https://github.com/nix-community/nix-on-droid/issues/495.
  build.activationBefore.installProotStaticEarly =
    let
      prootStatic = "${config.environment.files.prootStatic}/bin/proot-static";
    in
    ''
      if (test -e /bin/.proot-static.new && ! diff /bin/.proot-static.new ${prootStatic} > /dev/null) || \
          (! test -e /bin/.proot-static.new && ! diff /bin/proot-static ${prootStatic} > /dev/null); then
        $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents /bin
        $DRY_RUN_CMD cp $VERBOSE_ARG ${prootStatic} /bin/.proot-static.tmp
        $DRY_RUN_CMD chmod $VERBOSE_ARG u+w /bin/.proot-static.tmp
        $DRY_RUN_CMD mv $VERBOSE_ARG /bin/.proot-static.tmp /bin/.proot-static.new
      fi
    '';

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
