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
  };
}
