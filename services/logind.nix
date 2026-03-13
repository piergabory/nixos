{ ... }:

{
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
  };

  programs.zsh.shellAliases = {
    suspend = "systemctl suspend";
    hibernate = "systemctl hibernate";
  };
}
