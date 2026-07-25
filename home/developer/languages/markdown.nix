{ pkgs, ... }:

{
  programs.cargo.enable = true;

  home.packages = with pkgs; [
    prettier
    shellcheck
  ];

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft = {
      markdown = [ "prettier" ];
    };

    lsp.servers = {
      marksman.enable = true;
      markdown_oxide.enable = true;
    };
  };

  programs.zed-editor.extensions = [
    "markdown-oxide"
  ];
}
