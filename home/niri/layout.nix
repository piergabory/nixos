{ ... }:

{
  programs.niri.settings.layout = {
    gaps = 10;
    focus-ring.enable = false;
    default-column-width.proportion = 0.5;
    default-column-display = "normal";

    border = {
      enable = true;
      width = 1;
      active.color = "#fff";
      inactive.color = "#666";
      urgent.color = "#f00";
    };

    struts = {
      left = 10;
      right = 10;
      top = 0;
      bottom = 0;
    };

    preset-column-widths = [
      { proportion = 1.0 / 3.0; }
      { proportion = 1.0 / 2.0; }
      { proportion = 2.0 / 3.0; }
      { fixed = 1920; }
    ];
  };
}
