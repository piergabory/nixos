{ isDarwin, pkgs, ... }:

{
  # Zsh is configured here rather than through Home Manager, so Home Manager's
  # session variables (including Nixvim's defaultEditor) are not loaded by Zsh.
  # Keep the system defaults consistent with the shared Home Manager editor.
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';
  }
  // (
    if isDarwin then
      {
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
      }
    else
      {
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
      }
  );

  environment.systemPackages = with pkgs; [
    zsh-powerlevel10k
  ];
}
// (
  if isDarwin then
    { }
  else
    {
      users.defaultUserShell = pkgs.zsh;
    }
)
