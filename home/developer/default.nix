{
  lib,
  pkgs,
  isDroid ? false,
  ...
}:

{
  imports = [
    ./git.nix
    ./nixvim
  ]
  ++ lib.optionals (!isDroid) [
    ./languages
    ./opencode.nix
    ./zed-editor.nix
  ];

  config = lib.optionalAttrs (!isDroid) {
    programs.github-copilot-cli.enable = true;
    programs.helix.enable = true;

    home.packages = with pkgs; [
      tokscale
    ];
  };
}
