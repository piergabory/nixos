{ pkgs, ... }:

{
  users.defaultUserShell =  pkgs.zsh;

  users.users.piergabory = {
    isNormalUser = true;
    description = "Pierre Gabory";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}
