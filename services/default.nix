{ ... }:

{
  imports = [
    ./logind.nix
    ./samba.nix
    ./syncthing.nix
    ./pipewire.nix
    ./openssh.nix
    ./gnome.nix
  ];
}
