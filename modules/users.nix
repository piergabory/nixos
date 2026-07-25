{ pkgs, ... }:

{
  users.users."piergabory" = {
    isNormalUser = true;
    description = "Pierre Gabory";
    extraGroups = [
      "networkmanager"
      "libvirtd"
      "wheel"
      "scanner"
      "lp"
    ];
    shell = pkgs.zsh;
  };
}
