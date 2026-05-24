{ ... }:

{
  programs.nixvim.extraConfigLua = ''
    vim.diagnostic.config({
      severity_sort = true,
      virtual_text = { prefix = "●" },
      float = { border = "rounded" },
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function()
        vim.opt_local.relativenumber = false
      end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
      callback = function()
        vim.opt_local.relativenumber = true
      end,
    })

    vim.cmd.colorscheme("retrobox")
  '';
}
