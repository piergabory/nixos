{
  programs.nixvim.keymaps = [
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
}
