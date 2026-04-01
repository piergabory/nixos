{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zed-editor
    nil
    nixd
    vscode-css-languageserver
    vscode-json-languageserver
    gcc

    rustup
    rusty-man

    zeal

    wikiman
  ];
}
