{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.packages =
    with pkgs;
    [
      swiftlint
    ]
    ++ lib.optionals (!isDarwin) [
      swift
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
    conform-nvim.settings = {
      formatters_by_ft.swift = [ "swift_format" ];
      formatters.swift_format = lib.mkIf isDarwin {
        command = "/usr/bin/xcrun";
        prepend_args = [ "swift-format" ];
      };
    };
    lsp.servers.sourcekit = {
      enable = true;
      package = lib.mkIf isDarwin null;
      cmd = lib.mkIf isDarwin [
        "/usr/bin/xcrun"
        "sourcekit-lsp"
      ];
    };
  };

  programs.zed-editor.extensions = [
    "swift"
  ];

  programs.zed-editor.userSettings = {
    languages.Swift.language_servers = [ "sourcekit-lsp" ];
    lsp.sourcekit-lsp.binary =
      if isDarwin then
        {
          path = "/usr/bin/xcrun";
          arguments = [ "sourcekit-lsp" ];
        }
      else
        {
          path = lib.getExe pkgs.sourcekit-lsp;
        };
  };
}
