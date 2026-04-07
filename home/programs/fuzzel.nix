{ ... }:

{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        horizontal-pad = 10;
        vertical-pad = 10;
      };
      border.radius = 0;
    };
  };
}
