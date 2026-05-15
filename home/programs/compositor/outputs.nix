{ ... }:

{
  programs.niri.settings.outputs = {
    "DP-3" = {
      mode = {
        width = 3840;
        height = 2160;
        # refresh = 30.0;
      };
      scale = 1.5;
      position = {
        x = 0;
        y = 0;
      };
    };
    "DP-2" = {
      mode = {
        width = 3840;
        height = 2160;
        # refresh = 30.0;
      };
      scale = 1.5;
      transform.rotation = 180;
      position = {
        x = 0;
        y = -1440;
      };
    };
  };
}
