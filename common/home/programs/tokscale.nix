{ pkgs, ... }:

let
  tokscale = pkgs.writeShellScriptBin "tokscale" ''
    exec ${pkgs.steam-run}/bin/steam-run ${pkgs.bun}/bin/bunx tokscale@latest "$@"
  '';
in

{
  home.packages = [
    pkgs.bun
    tokscale
  ];
}
