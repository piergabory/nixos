{ ... }:

{
  programs.zsh.enable = true;

  programs.zsh.ohMyZsh = {
    enable = true;
    theme = "agnoster";
    plugins = [ "git" ];
  };
}
