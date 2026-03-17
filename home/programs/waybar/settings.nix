{ ... }:

{
  programs.waybar.settings.primary = {
    height = 18;

    modules-left = [ "niri/workspaces" ];
    modules-center = [ "niri/window" ];
    modules-right = [ "clock" ];

    "niri/workspaces".format = "{index}";
    "niri/window" = {
      format = "{title}";
      separate-outputs = true;
    };
    "clock".format =  "{:%H:%M, %A %B %d %Y }";
  };
}
