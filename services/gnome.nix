{ pkgs, ... }:

{
  services.gnome = {
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
    evolution-data-server.enable = true;
    core-apps.enable = true;
  };  

  programs.dconf.enable = true;
  
  security.pam.services.login.enableGnomeKeyring = true;
  
  # Optional: Add secret-tool for TUI secret management
  environment.systemPackages = with pkgs; [
    libsecret # provides secret-tool command
    seahorse # credential gui
    gnome-keyring
    gnome-control-center
  ];
}
