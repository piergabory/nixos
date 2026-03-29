{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zed-editor
    nil
    nixd
    rustup
    cargo-component
    vscode-css-languageserver
    vscode-json-languageserver
    gcc
  ];
}
