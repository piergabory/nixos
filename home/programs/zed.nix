{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zed-editor
    nil
    nixd
    rustup
    vscode-css-languageserver
    vscode-json-languageserver
  ];
}
