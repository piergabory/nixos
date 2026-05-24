{ ... }:

{
  programs.nixvim.plugins = {
    # Completion engine for LSP/path/snippet suggestions; use insert-mode completion menu.
    blink-cmp = {
      enable = true;
      settings = {
        completion.documentation.auto_show = true;
        keymap.preset = "default";
        signature.enabled = true;
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
    };

    # Community snippet collection for completion; expands through blink-cmp/LuaSnip.
    friendly-snippets.enable = true;

    # Snippet engine; use completion menu snippet expansion.
    luasnip.enable = true;

    # Adds pictograms/kinds to completion items; visible in completion menu.
    lspkind.enable = true;
  };
}
