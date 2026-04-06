{ ... }:

{
  programs.niri.settings.binds = {
    "Mod+T".action.spawn = "kitty";
    "Mod+Space".action.spawn = [ "fuzzel" ];
  };
}
