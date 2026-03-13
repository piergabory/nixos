{ ... }:

{
  programs.niri.settings.binds = {
    # Focus Window
    "Mod+Left".action.focus-column-left = [];
    "Mod+Right".action.focus-column-right = [];
    "Mod+WheelScrollRight".action.focus-column-right = [];
    "Mod+WheelScrollLeft".action.focus-column-left = [];
    "Mod+Shift+WheelScrollDown".action.focus-column-right = [];
    "Mod+Shift+WheelScrollUp".action.focus-column-left = [];
    "Mod+Down".action.focus-window-down = [];
    "Mod+Up".action.focus-window-up = [];

    # Move Window
    "Mod+Ctrl+Left".action.move-column-left = [];
    "Mod+Ctrl+Right".action.move-column-right = [];
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [];
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [];
    "Mod+Ctrl+Down".action.move-window-down = [];
    "Mod+Ctrl+Up".action.move-window-up = [];

    # Move Focus Screen
    "Mod+Shift+Left".action.focus-monitor-left = [];
    "Mod+Shift+Right".action.focus-monitor-right = [];
    "Mod+Shift+Down".action.focus-monitor-down = [];
    "Mod+Shift+Up".action.focus-monitor-up = [];

    # Move Window Screen
    "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
    "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
    "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
    "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];

    # Shape windows
    "Mod+R".action.switch-preset-column-width = [];
    "Mod+Shift+R".action.switch-preset-window-height = [];
    "Mod+Ctrl+R".action.reset-window-height = [];
    "Mod+F".action.maximize-column = [];
    "Mod+Shift+F".action.fullscreen-window = [];
    "Mod+Ctrl+F".action.expand-column-to-available-width = [];
  };
}
