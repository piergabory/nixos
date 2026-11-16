{
  lib,
  pkgs,
  isDarwin ? false,
  isDroid ? false,
  ...
}:

{
  imports = [
    ./git.nix
    ./nixvim
    ./opencode.nix
  ]
  ++ lib.optionals (!isDroid) [
    ./languages
    ./zed-editor.nix
  ]
  ++ lib.optionals isDarwin [
    ./darwin
  ];

  config = lib.optionalAttrs (!isDroid) {
    home.sessionVariables.GITLAB_HOST = "grpleg.gitlab.host";

    programs.github-copilot-cli.enable = true;
    programs.helix.enable = true;

    home.packages = with pkgs; [
      github-cli
      glab
      glab-tui

      (tokscale.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ zstd ];
        checkFlags = old.checkFlags ++ [
          "--skip=tui::ui::usage::tests::usage_reset_button_renders_when_credit_available"
        ];
      }))
    ];
  };
}
