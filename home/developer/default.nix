{ lib, pkgs, isDroid ? false, ... }:

{
  imports =
    [
      ./git.nix
      ./nixvim
    ]
    ++ lib.optionals (!isDroid) [
      ./languages
      ./opencode.nix
      ./zed-editor.nix
      ./tokscale.nix
    ];

  config = lib.optionalAttrs (!isDroid) {
    programs.github-copilot-cli.enable = true;
    programs.helix.enable = true;
    programs.tokscale.enable = true;

    home.packages = with pkgs; [
    ];
  };
}
