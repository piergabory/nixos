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
    theme = "Gruvbox dark";
    userSettings = {
      buffer_font_size = 14;
      buffer_font_family = "FiraCode Nerd Font";
      ui_font_size = 14;
      vim_mode = true;
      feature = {
        copilot = true;
      };
    };
  };
}
