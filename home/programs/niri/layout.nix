{ ... }:

{
  programs.niri.settings.layout = {
    struts = {
      left = 24;
      right = 24;
      top = 0;
      bottom = 0;
    };
    gaps = 24;

    default-column-width.proportion = 0.5;
    default-column-display = "normal";

    focus-ring.enable = false;

    border = {
      enable = true;
      width = 1;
      active.color = "#fff";
      inactive.color = "#666";
      urgent.color = "#f00";
    };

    preset-column-widths = [
      { proportion = 1.0 / 3.0; }
      { proportion = 1.0 / 2.0; }
      { proportion = 2.0 / 3.0; }
      { fixed = 1920; }
    ];
  };
}
