# Configuration of the Music Player Deamon

{ ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/piergabory/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "Pipewire audio sound output"
      }
    '';
  };
}
