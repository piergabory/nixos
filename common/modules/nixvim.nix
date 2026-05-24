{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    clipboard.register = "unnamedplus";
    colorscheme = "retrobox";

    extraPackages = with pkgs; [
      ansible-language-server
      bash-language-server
      clang-tools
      docker-compose-language-service
      dockerfile-language-server
      emmet-language-server
      fd
      gcc
      git
      gnumake
      jdt-language-server
      kotlin-language-server
      lazygit
      lua-language-server
      markdown-oxide
      marksman
      nil
      nixd
      nixfmt
      prettier
      pyright
      ripgrep
      ruff
      rust-analyzer
      shellcheck
      shfmt
      sourcekit-lsp
      stylua
      taplo
      terraform-ls
      tinymist
      tree-sitter
      typescript-language-server
      vim-language-server
      vscode-langservers-extracted
      yaml-language-server
    ];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      autoindent = true;
      autowrite = true;
      confirm = true;
      list = true;
      listchars = "tab:  ,trail:.,nbsp:+";
      expandtab = true;
      shiftround = true;
      shiftwidth = 2;
      tabstop = 2;
      smartcase = true;
      smartindent = true;
      ignorecase = true;
      inccommand = "split";
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      splitbelow = true;
      splitright = true;
      termguicolors = true;
      undofile = true;
      updatetime = 200;
      timeoutlen = 300;

      wildmenu = true;
      wildmode = "longest:full,full";
      wildoptions = "pum";
      pumheight = 12;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Explorer";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "Grep files";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<cr>";
        options.desc = "Help";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
        options.desc = "Search buffer";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Neogit<cr>";
        options.desc = "Git status";
      }
      {
        mode = "n";
        key = "<leader>gl";
        action = "<cmd>LazyGit<cr>";
        options.desc = "LazyGit";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xq";
        action = "<cmd>Trouble qflist toggle<cr>";
        options.desc = "Quickfix";
      }
      {
        mode = "n";
        key = "<leader>td";
        action = "<cmd>TodoTelescope<cr>";
        options.desc = "Todos";
      }
      {
        mode = "n";
        key = "<leader>aa";
        action = "<cmd>CodeCompanionActions<cr>";
        options.desc = "AI actions";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>ac";
        action = "<cmd>CodeCompanionChat Toggle<cr>";
        options.desc = "AI chat";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>ai";
        action = "<cmd>CodeCompanion<cr>";
        options.desc = "AI inline";
      }
      {
        mode = "n";
        key = "<leader>uf";
        action = "<cmd>Format<cr>";
        options.desc = "Format";
      }
      {
        mode = "n";
        key = "<leader>ft";
        action = "<cmd>ToggleTerm<cr>";
        options.desc = "Terminal";
      }
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>qa<cr>";
        options.desc = "Quit all";
      }
      {
        mode = "n";
        key = "<leader>ww";
        action = "<C-w>w";
        options.desc = "Other window";
      }
    ];

    plugins = {
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
          sourcekit.enable = true;
          taplo.enable = true;
          terraformls.enable = true;
          ts_ls.enable = true;
          vimls.enable = true;
          yamlls.enable = true;
        };
      };
      # Formatter integration with format-on-save; use :Format or <leader>uf.
      conform-nvim = {
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
      # GitHub Copilot inline AI completion; use :Copilot auth then accept with <M-l>.
      copilot-lua = {
        enable = true;
        settings = {
          panel.enabled = false;
          suggestion = {
            auto_trigger = true;
            enabled = true;
            keymap = {
              accept = "<M-l>";
              accept_line = "<M-L>";
              dismiss = "<C-]>";
              next = "<M-]>";
              prev = "<M-[>";
            };
          };
        };
      };
      # AI chat and inline editing through Copilot; use <leader>ac, <leader>ai, or <leader>aa.
      codecompanion = {
        enable = true;
        settings = {
          display.chat.window = {
            layout = "vertical";
            width = 0.4;
          };
          strategies = {
            chat.adapter = "copilot";
            inline.adapter = "copilot";
          };
        };
      };
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
      # Buffer tabline for open buffers; use :BufferLinePick or <leader>fb.
      bufferline.enable = true;
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
      # Modern command-line/messages UI; use :Noice for history/status.
      noice.enable = true;
      # Notification UI used by Noice and plugins; use :Notifications.
      notify.enable = true;
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
      # Indentation guides; use :IBLToggle to toggle guides.
      indent-blankline.enable = true;
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
      # Community snippet collection for completion; expands through blink-cmp/LuaSnip.
      friendly-snippets.enable = true;
      # Snippet engine; use completion menu snippet expansion.
      luasnip.enable = true;
      # Adds pictograms/kinds to completion items; visible in completion menu.
      lspkind.enable = true;
      # Personal wiki/notes plugin; use :VimwikiIndex.
      vimwiki.enable = true;
      # Filetype icons for Telescope/Neo-tree/statusline; works automatically.
      web-devicons.enable = true;
    };

    userCommands.Format.command = "lua require('conform').format({ async = true, lsp_format = 'fallback' })";

    extraConfigLua = ''
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { prefix = "●" },
        float = { border = "rounded" },
      })
    '';
  };
}
