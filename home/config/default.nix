{ ... }:

{
  xdg.configFile = {
    "fuzzel/fuzzel.ini".source = ./sources/fuzzel.toml;
    "kdeglobals".source = ./sources/kdeglobals.toml;
    "btop/btop.conf".source = ./sources/btop.conf;
    "rmpc/config.ron".source = ./sources/rmpc/config.ron;
    "rmpc/themes/theme.ron".source = ./sources/rmpc/theme.ron;
    "kitty/kitty-themes/themes".source = ./sources/kitty/themes;
  };
}
