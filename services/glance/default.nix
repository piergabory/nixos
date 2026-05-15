{ ... }:

{
  imports = [
    ./nginx.nix
    ./page.nix
    ./secrets.nix
    ./settings.nix
    ./systemd-status.nix
  ];
}
