{ ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings.main.pad = "8x8";
  };

  programs.starship = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.niri.settings = {
    binds = {
      "Mod+T".action.spawn = "footclient";
    };

    spawn-at-startup = [
      { sh = "foot --server"; }
      { sh = "eval $(starship init zsh)"; }
    ];
  };
}
