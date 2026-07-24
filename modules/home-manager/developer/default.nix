{
    imports = [
      ./languages
      ./git.nix
      ./nixvim
      ./zed-editor.nix
      ./tokscale.nix
    ];

    config = {
      # programs.opencode.enable = true;
      programs.github-copilot-cli.enable = true;
      programs.helix.enable = true;
      programs.tokscale.enable = true;
    };
}
