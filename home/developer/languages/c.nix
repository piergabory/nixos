{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libclang
    gcc
    clang-tools
    lldb
  ];

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft = {
      c = [ "clang_format" ];
      cpp = [ "clang_format" ];
    };

    lsp.servers.clangd.enable = true;
  };
}
