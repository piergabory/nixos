{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    swift
    swiftlint
    swiftpm
    swift-format
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with darwin; [
    xcode_27
    xcode_26_6_Apple_silicon
  ]);

  # programs.nixvim.plugins = {
    # conform-nvim.settings.formatter_by_ft = {
      # Does not exist
      # swift = [ "swift-format" ];
    # };

    # Does not exist
    # lsp.servers.swift.enable = true;
  # };

  programs.zed-editor.extensions = [
    "swift"
  ];
}
