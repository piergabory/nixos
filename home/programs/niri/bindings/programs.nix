{ ... }:

{
  programs.niri.settings.binds = {
    "Mod+T".action.spawn = "kitty";
    "Mod+Space".action.spawn = [ "fuzzel" ];
    "Mod+E".action.spawn = "thunar";
  };
}
