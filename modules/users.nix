{ pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

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

  systemd.tmpfiles.rules = [
    "d /var/lib/AccountsService/icons 0755 root root -"
    "L+ /var/lib/AccountsService/icons/piergabory - - - - ${../assets/pierre.jpg}"
  ];
}
