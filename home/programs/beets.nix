
{
  programs.beets = {
    enable = true;

    settings = {
      directory = "~/Music";
      library = "~/.config/beets/library.db";

      plugins = [
        "fetchart"
        "embedart"
        "lyrics"
      ];

      fetchart.auto = true;
      embedart.auto = true;
      lyrics.auto = true;
    };
  };
}
