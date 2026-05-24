{ ... }:

{

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    opts = {
      number = true;
      relativenumber = true;
      autoindent = true;
      autowrite = true;
      confirm = true;
      list = true;
      expandtab = true;
      shiftround = true;
      shiftwidth = 3;
      smartcase = true;
      smartindent = true;

      wildmenu = true;
      wildmode = "longest:full,full";
      wildoptions = "pum";
      pumheight = 12;
    };

    plugins = {
      blink-cmp = {
        enable = true;
      };
      lsp = {
        enable = true;
        servers.nixd.enable = true;
      };
      lualine.enable = true;
      telescope.enable = true;
      image.enable = true;
      gitsigns.enable = true;
      which-key.enable = true;
      vimwiki.enable = true;
      web-devicons.enable = true;
    };
  };
}
