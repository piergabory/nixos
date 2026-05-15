{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    vim
    helix # Helix text editor
    mdadm # Software RAID for /storage
    kitty # support for kitty ssh client
  ];
    
  environment.shells = with pkgs; [ zsh ];
}
