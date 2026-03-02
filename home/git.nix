{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Pierre Gabory";
      email = "mail@piergabory.net";
      pull.rebase = true;
    };
  };

  home.packages = with pkgs; [
    gitg
    smartgit
  ];
}
