{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    settings.theme = lib.mkForce "gruvbox_dark_hard";
  };

  home.packages = with pkgs; [
    zellij # Terminal workspace (like tmux)
    
    cargo
    clippy
    rustc
    rust-analyzer
    rustfmt

    pkg-config

    openssl

    nil
    nixd
    nixfmt

    libclang
    gcc
    lldb

    htmlhint
    superhtml
    vscode-css-languageserver
    javascript-typescript-langserver
    coc-css
  ];

  programs.zsh.sessionVariables = {
    EDITOR = "hx";
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openssl ]}:$LD_LIBRARY_PATH";
  };
}
