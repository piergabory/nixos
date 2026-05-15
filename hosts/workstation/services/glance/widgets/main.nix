{ config }:

let
  lib = import ./lib.nix;
in

(import ./feeds.nix { inherit lib; })
++ (import ./operations.nix { inherit config lib; })
++ (import ./media.nix { inherit config lib; })
++ (import ./social.nix { inherit lib; })
