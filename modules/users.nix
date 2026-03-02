{ pkgs, ... }:

{
  users.users.piergabory = {
    isNormalUser = true;
    description = "Pierre Gabory";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}
