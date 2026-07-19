{ ... }:

{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "rust"
      "toml"
      "json"
      "yaml"
      "git-firefly"
      "html"
    ];
    userSettings = {
      vim_mode = true;
      feature = {
        copilot = true;
      };
    };
  };
}
