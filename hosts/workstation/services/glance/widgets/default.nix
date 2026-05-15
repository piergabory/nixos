{ config }:

{
  main = import ./main.nix { inherit config; };
  aside = import ./aside.nix;
}
