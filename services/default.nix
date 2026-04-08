{ ... }:

{
  imports = [
    ./logind.nix
    ./syncthing.nix
    ./pipewire.nix
    ./openssh.nix
    ./fprintd.nix
    ./laptop.nix
  ];
}
