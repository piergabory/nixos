{ pkgs, ... }:

{
  imports = [
    ./languages
    ./git.nix
    ./nixvim
    ./zed-editor.nix
    ./tokscale.nix
  ];

  config = {
    programs.opencode = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.opencode;
    };
    programs.github-copilot-cli.enable = true;
    programs.helix.enable = true;
    programs.tokscale.enable = true;

    home.packages = with pkgs; [
      warp-terminal
    ];
  };
}
