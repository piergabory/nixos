{ ... }:

{
  programs.nixvim.plugins = {
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
  };
}
