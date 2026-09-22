{ lib, pkgs, isDroid ? false, ... }:

{
  imports =
    [
      ./git.nix
      ./nixvim
    ]
    ++ lib.optionals (!isDroid) [
      ./languages
      ./zed-editor.nix
      ./tokscale.nix
    ];

  config = lib.optionalAttrs (!isDroid) {
    programs.opencode = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.opencode;
    };
    programs.github-copilot-cli.enable = true;
    programs.helix.enable = true;
    programs.tokscale.enable = true;

    home.packages = with pkgs; [
    ];
  };
}
