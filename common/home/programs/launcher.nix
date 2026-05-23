{ ... }:

{
  programs.vicinae = {
    enable = true;
    systemd.enable = true;

    settings = {
    };
  };

  programs.niri.settings.binds = {
    "Mod+Space".action.spawn = [ "vicinae" "open" ];
  };
}
