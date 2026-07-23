{ pkgs, ... }:

{
  home.packages = with pkgs; [
    shfmt
    gnumake
    pyright
    stylua
    lua-language-server
    yaml-language-server
    bash-language-server
    vim-language-server
  ];

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft = {
      python = [ "ruff_format" ];
      sh = [ "shfmt" ];
      toml = [ "taplo" ];
      yaml = [ "prettier" ];
      json = [ "prettier" ];
      jsonc = [ "prettier" ];
    };

    lsp.servers = {
      bashls.enable = true;
      pyright.enable = true;
      lua_ls.enable = true;
      yamlls.enable = true;
      vimls.enable = true;
    };
  };

  programs.zed-editor.extensions = [
    "json"
    "toml"
    "yaml"
  ];
}
