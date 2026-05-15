{ ... }:

{
  services.logind.settings.Login = {
    HandlePowerKey = "poweroff";
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };
}
