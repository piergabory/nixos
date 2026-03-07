{ ... }:

{
  # Fix Zen browser border being strangely thin
  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "zen-beta"; } ];
      border.width = 2;
    }
  ];
}
