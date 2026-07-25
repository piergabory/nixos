{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    # Home Manager still manages Zed's config on macOS, without building Zed.
    # Install the official app separately (for example, from zed.dev).
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.zed-editor;

    extensions = [
      "git-firefly"
    ];

    userSettings = {
      vim_mode = true;
      feature = {
        copilot = true;
      };
    };
  };
}
