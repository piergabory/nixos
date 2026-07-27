let
  top = {
    mode = {
      width = 3840;
      height = 2160;
    };
    scale = 1.5;
    transform.rotation = 180;
    position = {
      x = 0;
      y = -1440;
    };
  };
  bottom = {
    mode = {
      width = 3840;
      height = 2160;
    };
    scale = 1.5;
    position = {
      x = 0;
      y = 0;
    };
  };
in
{
  mainUser.homeConfiguration = {
    programs.niri.settings.outputs = {
      DP-3 = top;
      DP-2 = bottom;
      DP-6 = top;
      DP-5 = bottom;
    };
  };
}
