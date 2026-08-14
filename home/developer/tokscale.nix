{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.programs.tokscale;
in
{
  options.programs.tokscale = {
    enable = mkEnableOption "AI Token usage utility";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bun
      (writeShellScriptBin "tokscale" ''
        exec ${optionalString pkgs.stdenv.hostPlatform.isLinux "${pkgs.steam-run}/bin/steam-run"} ${pkgs.bun}/bin/bunx tokscale@latest "$@"
      '')
    ];
  };
}
