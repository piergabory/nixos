{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.musicLibrary;
in
{
  options.musicLibrary = {
    enable = mkEnableOption "Manage music library";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    programs = {
      rmpc.enable = true;

      beets = {
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
    };

    services.mpd = {
      enable = true;
      musicDirectory = "~/Music";

      extraConfig = ''
        audio_output {
          type "pipewire"
          name "Pipewire audio sound output"
        }

        audio_output {
          type "fifo"
          name "my_fifo"
          path "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };

    home.packages = [ pkgs.cava ];
  };
}
