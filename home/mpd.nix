# Configuration of the Music Player Deamon

{ ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/piergabory/Music";

    # Second is for rmpc/cava music visualiser
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "Pipewire audio sound output"
      }

      audio_output {
         type   "fifo"
         name   "my_fifo"
         path   "/tmp/mpd.fifo"
         format "44100:16:2"
      }
    '';
  };
}
