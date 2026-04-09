{ ... }:

{
  imports = [
    ./audio.nix
    ./playback.nix
    ./windows.nix
  ];

  programs.niri.settings.binds = {
    "Mod+Shift+H".action.show-hotkey-overlay = [];
    "Mod+Shift+E".action.quit.skip-confirmation = false;

    "Mod+O" = {
      repeat = false;
      action.toggle-overview = [];
    };

    "Mod+Q" = {
      repeat = false;
      action.close-window = [];
    };
  };
}
