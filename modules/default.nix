{ isDarwin, lib, ... }:

{
  imports = [
    ./user
    ./shell.nix
    ./stylix.nix
  ] ++ lib.optionals (!isDarwin) [
    ./desktop
    ./homelab
    ./syncthing
    ./audio.nix
    ./bluetooth.nix
    ./keyboards.nix
    ./openssh.nix
    ./photography.nix
  ];
}
