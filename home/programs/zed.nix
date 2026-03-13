{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zed-editor

    # Nix language server
    nil
    nixd

    # Rust toolchain
    rustup
  ];
}
