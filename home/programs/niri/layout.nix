{ ... }:

{
  programs.niri.settings.layout = {
    struts = {
      left = 0;
      right = 0;
      top = -10;
      bottom = 0;
    };
    gaps = 10;

    default-column-width.proportion = 0.5;
    default-column-display = "normal";

    focus-ring.enable = false;

    border = {
      enable = true;
      width = 1;
      active.color = "#5A6378";
      inactive.color = "#1B1F29";
      urgent.color = "#D95757";
    };

    preset-column-widths = [
      { proportion = 1.0 / 3.0; }
      { proportion = 1.0 / 2.0; }
      { proportion = 2.0 / 3.0; }
      { fixed = 1920; }
    ];

    insert-hint.display.color = "#fabd2f66";
    background-color = "#0D1017";
  };
}
