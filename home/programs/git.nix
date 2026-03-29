{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Pierre Gabory";
      email = "mail@piergabory.net";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  home.packages = with pkgs; [
    lazygit
  ];
}
