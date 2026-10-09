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
      (tokscale.overrideAttrs (old: {
        # This UI test fails under the nixpkgs build environment because the
        # rendered usage screen omits the reset button; keep the remaining
        # tokscale test suite enabled.
        checkFlags = old.checkFlags ++ [
          "--skip=tui::ui::usage::tests::usage_reset_button_renders_when_credit_available"
        ];
      }))
      opencode-desktop
    ];
  };
}
