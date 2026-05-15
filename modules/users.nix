{ pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  users.users.piergabory = {
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
