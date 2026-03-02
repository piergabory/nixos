{ ... }:

{
  programs.niri.settings.outputs = {
    "DP-8" = {
      mode = { width = 3840; height = 2160; };
      scale = 1.5;
      position = { x = 0; y = 0; };
    };

    "DP-11" = {
      mode = { width = 3840; height = 2160; };
      scale = 1.5;
      position = { x = 0; y = 0; };
    };

    "DP-7" = {
      mode = { width = 3840; height = 2160; };
      scale = 1.5;
      transform.rotation = 180;
      position = { x = 0; y = -1440; };
    };

    "DP-12" = {
      mode = { width = 3840; height = 2160; };
      scale = 1.5;
      transform.rotation = 180;
      position = { x = 0; y = -1440; };
    };
  };
}
