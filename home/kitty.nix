{ ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 10000;
      background_opacity = "0.8";
      hide_window_decorations = "yes";
      window_padding_width = 10;
      font_size = 12.0;
      title = "console";
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
  };
}
