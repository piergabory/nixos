{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.audio;
in {
  options.modules.audio = {
    enable = mkEnableOption "Enable audio support";
    enableMusic = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      audio.enable = true;
      wireplumber.enable = true;
      pulse.enable = true;
    };

    security.rtkit.enable = true;

    services.mpd = mkIf cfg.enableMusic {
      enable = true;
      settings = {
        music_directory = "/home/piergabory/Music";
        audio_output = [
          {
            type = "pipewire";
            name = "Pipewire audio sound output";
          }
          {
            # For CAVA visualiser
            type = "fifo";
            name = "my_fifo";
            path = "/tmp/mpd.fifo";
            format = "44100:16:2";
          }
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      pwvucontrol # Audio controls GUI (GNOME)
      (mkIf cfg.enableMusic cava) # Music visualiser
    ];
  };
}
