{ ... }:

{
  programs.nixvim.plugins = {
    # Syntax parsing/highlighting and indentation; use :InspectTree for parser inspection.
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # Sticky code context at the top of the window; use :TSContextToggle.
    treesitter-context.enable = true;

    # Treesitter-aware text objects for selections/motions; use configured text object motions.
    treesitter-textobjects.enable = true;

    # Statusline with mode/file/git/LSP info; visible automatically at the bottom.
    lualine.enable = true;

    # Fuzzy finder for files, text, buffers, and help; use <leader>ff or :Telescope.
    telescope.enable = true;

    # File explorer tree; use <leader>e or :Neotree toggle.
    neo-tree.enable = true;

    # Inline image rendering support; use image-capable buffers/markdown previews.
    image.enable = true;

    # Git signs and hunk actions in the gutter; use :Gitsigns preview_hunk.
    gitsigns.enable = true;

    # Full-screen Git UI inside Neovim; use <leader>gg or :Neogit.
    neogit.enable = true;

    # Terminal UI for lazygit; use <leader>gl or :LazyGit.
    lazygit.enable = true;

    # Popup guide for keybindings; press <leader> and wait or use :WhichKey.
    which-key.enable = true;

    # Diagnostics, quickfix, and references list UI; use <leader>xx or :Trouble.
    trouble.enable = true;

    # Finds TODO/FIXME-style comments; use <leader>td or :TodoTelescope.
    todo-comments.enable = true;

    # Fast jump/search motions; use s/S style Flash motions.
    flash.enable = true;

    # Smart commenting operator; use gcc or gc in visual mode.
    comment.enable = true;

    # Auto-inserts matching brackets/quotes; works automatically in insert mode.
    nvim-autopairs.enable = true;

    # Add/change/delete surrounding delimiters; use ys, cs, or ds.
    nvim-surround.enable = true;

    # Rainbow highlighting for nested delimiters; works automatically.
    rainbow-delimiters.enable = true;

    # Highlights other references to symbol under cursor; works automatically.
    illuminate.enable = true;

    # Session persistence across projects; use :SessionRestore or :SessionSave.
    persistence.enable = true;

    # Project root detection for Telescope/LSP; use :Telescope projects if available.
    project-nvim.enable = true;

    # Floating/split terminal inside Neovim; use <leader>ft or :ToggleTerm.
    toggleterm.enable = true;

    # Improved vim.ui prompts/select menus; used automatically by plugins.
    dressing.enable = true;

    # LSP progress notifications; visible automatically during server work.
    fidget.enable = true;

    # Detects indentation style per file; works automatically.
    sleuth.enable = true;

    # Reopens files at the last cursor position; works automatically.
    lastplace.enable = true;

    # Lua development helpers for Neovim config/plugins; use with lua_ls automatically.
    lazydev.enable = true;

    # Personal wiki/notes plugin; use :VimwikiIndex.
    vimwiki.enable = true;

    # Filetype icons for Telescope/Neo-tree/statusline; works automatically.
    web-devicons.enable = true;
  };
}
