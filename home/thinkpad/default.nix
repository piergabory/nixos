{ pkgs, lib, ... }:

{
  imports = [
    ./waybar.nix
    ./niri.nix
  ];

  programs.btop.package = lib.mkForce pkgs.btop;
}
