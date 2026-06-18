{ config }:

let
  lib = import ./lib.nix;
  inherit (lib) split;
  operations = import ./operations.nix { inherit config lib; };
  media = import ./media.nix { inherit config lib; };
  social = import ./social.nix { inherit lib; };
in

operations.top
++ [
  (split [
    operations.immichStats
    operations.piholeStats
  ])
  (split [
    operations.backups
    operations.systemdServices
  ])
  (split media)
  (split social)
]
