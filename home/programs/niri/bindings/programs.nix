{ ... }:

{
  programs.niri.settings.binds = {
    "Mod+T".action.spawn = "kitty";
    "Mod+D".action.spawn = [ "rofi"  "-show"  "drun" ];
    "Mod+Space".action.spawn = [ "rofi" "-show" "combi" ];
  };
}
