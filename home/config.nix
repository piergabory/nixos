{ ... }:

{
  programs.fuzzel.enable = true;
  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;

  xdg.configFile = {
    "fuzzel/fuzzel.ini".source = ./config/fuzzel.toml;
    "kdeglobals".source = ./config/kdeglobals.toml;
    "btop/btop.conf".source = ./config/btop.conf;
  };
}
