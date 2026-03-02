{ ... }:

{
  programs.alacritty.enable = true;
  programs.fuzzel.enable = true;
  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;

  xdg.configFile = {
   # "niri/config.kdl".source = ./config/niri.kdl;
   "waybar/config.jsonc".source = ./config/waybar/config.jsonc;
   "waybar/style.css".source = ./config/waybar/style.css;
   "alacritty/alacritty.toml".source = ./config/alacritty.toml;
   "fuzzel/fuzzel.ini".source = ./config/fuzzel.toml;
   "kdeglobals".source = ./config/kdeglobals.toml;
  };
}
