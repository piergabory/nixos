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
  ]
  ++ lib.optionals (!isDroid) [
    ./languages
    ./opencode.nix
    ./zed-editor.nix
  ]
  ++ lib.optionals isDarwin [
    ./darwin
  ];

  config = lib.optionalAttrs (!isDroid) {
    programs.github-copilot-cli.enable = true;
    programs.helix.enable = true;

    home.packages = with pkgs; [
      hunk # Diff review TUI
      github-cli

      (tokscale.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ zstd ];
        checkFlags = old.checkFlags ++ [
          "--skip=tui::ui::usage::tests::usage_reset_button_renders_when_credit_available"
        ];
      }))
    ];
  };
}
