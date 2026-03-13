{ ... }:

{
  xdg.configFile = {
    "btop/btop.conf".source = ./sources/btop.conf;
    "rmpc/config.ron".source = ./sources/rmpc/config.ron;
    "rmpc/themes/theme.ron".source = ./sources/rmpc/theme.ron;
  };
}
