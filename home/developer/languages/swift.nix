{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.packages =
    with pkgs;
    [
      swift
      swiftlint
      swiftpm
      swift-format
    ]
    ++ lib.optionals isDarwin [
      pkgs.darwin.xcode_27
    ];

  home.file."Applications/Home Manager Apps/Xcode 26.6.app" = lib.mkIf isDarwin {
    source = pkgs.darwin.xcode_26_6_Apple_silicon;
  };

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft.swift = [ "swift_format" ];
    lsp.servers.sourcekit.enable = true;
  };

  programs.zed-editor.extensions = [
    "swift"
  ];

  programs.zed-editor.userSettings = {
    languages.Swift.language_servers = [ "sourcekit-lsp" ];
    lsp.sourcekit-lsp.binary.path = lib.getExe pkgs.sourcekit-lsp;
  };
}
