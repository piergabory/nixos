{ pkgs, ... }:

{
  programs.nixvim.plugins = {
    # Built-in language server client; use :LspInfo to inspect active servers.
    lsp = {
      enable = true;
      servers = {
        ansiblels = {
          enable = true;
          package = pkgs.ansible-language-server;
        };
        bashls.enable = true;
        clangd.enable = true;
        cssls.enable = true;
        docker_compose_language_service.enable = true;
        dockerls.enable = true;
        emmet_language_server.enable = true;
        html.enable = true;
        jdtls.enable = true;
        jsonls.enable = true;
        kotlin_language_server.enable = true;
        lua_ls.enable = true;
        marksman.enable = true;
        markdown_oxide.enable = true;
        nil_ls.enable = true;
        nixd.enable = true;
        pyright.enable = true;
        ruff.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
          installRustfmt = true;
        };
        taplo.enable = true;
        terraformls.enable = true;
        ts_ls.enable = true;
        vimls.enable = true;
        yamlls.enable = true;
      };
    };
  };
}
