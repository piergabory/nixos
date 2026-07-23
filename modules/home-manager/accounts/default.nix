{
  imports = [
    ./homelab.nix
    ./icloud.nix
  ];

  config.accounts = {
    homelab.enable = true;
    icloud.enable = true;
  };
}
