{ ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 10000;
      hide_window_decorations = "yes";
      window_padding_width = 2;
      title = "console";
      
      # Performance optimizations
      shell_integration = "no";
      sync_to_monitor = true;
      wayland_titlebar_color = "system";
    };
  };
}
