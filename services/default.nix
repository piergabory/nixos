{ ... }:

{
  imports = [
    ./logind.nix
    ./syncthing.nix
    ./pipewire.nix
    ./openssh.nix
    ./fprintd.nix
    ./home-server.nix
    ./laptop.nix
  ];
}
