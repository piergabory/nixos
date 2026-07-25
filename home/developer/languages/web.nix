{ pkgs, ... }:

{
  home.packages = with pkgs; [
    htmlhint
    superhtml
    coc-css
    prettier
    vscode-css-languageserver
    javascript-typescript-langserver
    typescript-language-server
  ];

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft = {
      css = [ "prettier" ];
      html = [ "prettier" ];
      javascript = [ "prettier" ];
      javascriptreact = [ "prettier" ];
      typescript = [ "prettier" ];
      typescriptreact = [ "prettier" ];
    };

    lsp.servers = {
      html.enable = true;
      jsonls.enable = true;
      cssls.enable = true;
      ts_ls.enable = true;
    };
  };
}
