{
  programs.nixvim.opts = {
    number = true;
    relativenumber = false;
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
}
