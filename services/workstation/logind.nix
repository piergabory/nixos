{ ... }:

{
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    PowerKeyIgnoreInhibited = false;
  };

  programs.zsh.shellAliases = {
    suspend = "systemctl suspend";
    hibernate = "systemctl hibernate";
  };
}
