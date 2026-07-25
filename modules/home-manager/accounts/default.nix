{
  imports = [
    ./secrets
    ./homelab.nix
  ];

  config = {
    accounts = {
      homelab.enable = true;
    };

    programs.thunderbird.profiles.default.isDefault = true;
  };
}
