# Shell and CLI environment for nix-on-droid.
#
# On NixOS and nix-darwin this is covered by `modules/shell.nix` (a system
# module using `environment.systemPackages` / `users.defaultUserShell`) and by
# `home/programs`, which is full of desktop GUI apps. Neither applies to
# nix-on-droid, so without this module the phone gets zsh as its login shell
# with no zshrc, no prompt and none of the usual CLI tools.
{ pkgs, ... }:

{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # Plain string => mkOrder 1000, i.e. after completion (570) and
      # autosuggestions (700) but before syntax highlighting (1200), which is
      # the order powerlevel10k expects.
      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      '';
    };

    bat.enable = true;
    btop.enable = true;
    eza.enable = true;
    fzf.enable = true;
    tmux.enable = true;
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    fastfetch
    fd
    jq
    openssh
    ripgrep
    tree
    unzip
    wget
  ];
}
