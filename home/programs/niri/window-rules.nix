{ ... }:

{
  programs.niri.settings.window-rules = [
    {
      draw-border-with-background = false;
    }

    # Fix Zen browser border being strangely thin
    {
      matches = [ { app-id = "zen-beta"; } ];
      border.width = 2;
    }

    {
      matches = [ { app-id = "sirula"; } ];
      open-floating = true;
      border.enable = false;
    }
  ];
}
