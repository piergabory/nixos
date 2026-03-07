{ ... }:

{
  programs.alacritty.enable = true;
  programs.fuzzel.enable = true;
  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;

  xdg.configFile = {
    "alacritty/alacritty.toml".source = ./config/alacritty.toml;
    "fuzzel/fuzzel.ini".source = ./config/fuzzel.toml;
    "kdeglobals".source = ./config/kdeglobals.toml;
  };
}
