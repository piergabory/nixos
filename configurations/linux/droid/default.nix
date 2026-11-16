{
  config,
  inputs,
  lib,
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


  mainUser.homeProfile = ../../../home/cli.nix;

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
  build.activationBefore = lib.mkAfter {
    installProotStaticEarly =
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
    setPriorityHomeManagerPath = ''
      if [[ ! -e "${config.user.home}/.nix-profile/manifest.json" ]]; then
        if nix-env -q | grep '^home-manager-path$'; then
          $DRY_RUN_CMD nix-env $VERBOSE_ARG --set-flag priority 120 home-manager-path
        fi
      fi
    '';
  };

  # Upstream parses the pre-Nix-2.20 tabular `nix profile list` output.
  # Modern Nix prints labelled blocks, leaving `nix profile remove` with no
  # arguments. Use the stable JSON format and preserve unrelated user entries.
  # These upstream options use the shallow `types.attrs`, so ordering must
  # apply to the whole set (a per-entry mkForce is not interpreted).
  build.activation = lib.mkAfter {
    installPackages = ''
    if [[ -e "${config.user.home}/.nix-profile/manifest.json" ]]; then
      nix_previous="${config.nix.package}/bin/nix"
      old_entries="$($nix_previous profile list --json | ${pkgs.jq}/bin/jq -r '
        .elements | to_entries[]
        | select(any(.value.storePaths[]; endswith("-nix-on-droid-path")))
        | .key')"
      if [[ -n "$old_entries" ]]; then
        while IFS= read -r entry; do
          $DRY_RUN_CMD "$nix_previous" profile remove "$entry"
        done <<< "$old_entries"
      fi
      # Explicit user-installed packages retain priority over the managed set.
      # Roll back the removal if installation fails (upstream requires these
      # to be separate operations, see Nix issue #6349).
      if ! $DRY_RUN_CMD "$nix_previous" profile install --priority 10 ${config.environment.path}; then
        if [[ -n "$old_entries" ]]; then
          $DRY_RUN_CMD "$nix_previous" profile rollback
        fi
        exit 1
      fi
      unset nix_previous old_entries
    else
      $DRY_RUN_CMD nix-env --install ${config.environment.path}
    fi
    '';
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
      isDarwin = false;
    };
  };
}
