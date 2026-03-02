{ ... }:

{
  programs.niri.settings.binds = {
    "XF86AudioPlay" = {
      action.spawn = ["playerctl" "play-pause"];
      allow-when-locked = true;
      cooldown-ms = 150;
    };
    "XF86AudioStop" = {
      action.spawn = ["playerctl" "stop"];
      allow-when-locked = true;
      cooldown-ms = 150;
    };
    "XF86AudioPrev" = {
      action.spawn = ["playerctl" "previous"];
      allow-when-locked = true;
      cooldown-ms = 150;
    };
    "XF86AudioNext" = {
      action.spawn = ["playerctl" "next"];
      allow-when-locked = true;
      cooldown-ms = 150;
    };
  };
}
