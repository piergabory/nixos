{
  imports = [
    ./secrets
    ./modules
    ./services
  ];

  config = {
    time.timeZone = "Europe/Paris";

    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };

    networking.networkmanager.enable = true;
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      trusted-users = [
        "root"
        "piergabory"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    system = {
      autoUpgrade = {
        enable = true;
        allowReboot = true;
        channel = "https://channels.nixos.org/nixos-unstable";
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      stateVersion = "26.05"; # Did you read the comment?
    };
  };
}
