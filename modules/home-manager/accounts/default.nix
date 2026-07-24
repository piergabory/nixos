{
  imports = [
    ./homelab.nix
    ./icloud.nix
  ];

  config = {
    accounts = {
      homelab.enable = true;
      icloud = {
        enable = true;
        appleId = "piergabory@icloud.com";
        realName = "Pierre Gabory";
      };
    };

    programs.thunderbird.profiles.default.isDefault = true;
  };
}
