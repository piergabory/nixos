{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    settings.theme = lib.mkForce "base16_transparent";
  };

  home.packages = with pkgs; [
    gcc
    rustup
    pkg-config
    openssl
    zsh
    nil
    nixd
  ];

  programs.zsh.sessionVariables = {
    EDITOR = "hx";
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openssl ]}:$LD_LIBRARY_PATH";
  };
}
