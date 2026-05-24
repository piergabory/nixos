{ ... }:

{
  programs.nixvim = {
    # Formatter integration with format-on-save; use :Format or <leader>uf.
    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
        formatters_by_ft = {
          c = [ "clang_format" ];
          cpp = [ "clang_format" ];
          css = [ "prettier" ];
          html = [ "prettier" ];
          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          json = [ "prettier" ];
          jsonc = [ "prettier" ];
          lua = [ "stylua" ];
          markdown = [ "prettier" ];
          nix = [ "nixfmt" ];
          objective-c = [ "clang_format" ];
          python = [ "ruff_format" ];
          rust = [ "rustfmt" ];
          sh = [ "shfmt" ];
          swift = [ "swift_format" ];
          terraform = [ "terraform_fmt" ];
          toml = [ "taplo" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          yaml = [ "prettier" ];
        };
      };
    };

    userCommands.Format.command = "lua require('conform').format({ async = true, lsp_format = 'fallback' })";
  };
}
