{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    vim
    helix # Helix text editor
    kitty # support for kitty ssh client
  ];
    
  environment.shells = with pkgs; [ zsh ];
}
