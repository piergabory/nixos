{ ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings.main.pad = "8x8";
  };

  programs.niri.settings = {
    binds = {
      "Mod+T".action.spawn = "footclient";
    };

    spawn-at-startup = [
      { sh = "foot --server"; }
    ];
  };
}
