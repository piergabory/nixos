{ pkgs, ... }:

{
  imports = [
    ./developer/git.nix
    ./developer/nixvim
    ./developer/opencode.nix
    ./programs/ssh.nix
  ];

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      ragenix
      yazi
    ];
  };

  programs = {
    btop.enable = true;
    zellij.enable = true;
  };

  # CLI-only profile. Auto-enabling every Stylix target also pulls in the
  # GNOME/GTK targets, which write dconf settings and need a desktop D-Bus
  # service. Theme the terminal tools explicitly instead.
  stylix = {
    enable = true;
    autoEnable = false;
    targets = {
      btop.enable = true;
      font-packages.enable = true;
      fontconfig.enable = true;
      nixvim.enable = true;
      opencode.enable = true;
      yazi.enable = true;
      zellij.enable = true;
    };
  };
}
