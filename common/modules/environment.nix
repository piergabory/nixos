{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];
    
  environment.shells = with pkgs; [ zsh ];
}
