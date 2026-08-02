{ isDarwin, lib, ... }:

{
  imports = [
    ./user
    ./shell.nix
    ./stylix.nix
  ] ++ lib.optionals (!isDarwin) [
    ./desktop
    ./homelab
    ./offsite-backup
    ./syncthing
    ./audio.nix
    ./auto-upgrade.nix
    ./bluetooth.nix
    ./openssh.nix
    ./photography.nix
  ];
}
