{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zed-editor
    nil
    nixd
    vscode-css-languageserver
    vscode-json-languageserver
    gcc

    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy

    zeal
    wikiman
  ];
} 
