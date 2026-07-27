{
  imports = [
    ../modules
  ];

  config = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      trusted-users = [ "root" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    mainUser.enable = true;
  };
}
