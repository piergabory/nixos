{ ... }:

{
  programs.fuzzel.enable = true;
  services.mako.enable = true;

  home = {
    username = "piergabory";
    homeDirectory = "/home/piergabory";
    stateVersion = "25.11";
  };
}
