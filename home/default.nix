{ ... }:

{
  imports = [
    ./config
    ./environment
    ./programs
    ./services

    ./home.nix
    ./packages.nix
  ];
}
