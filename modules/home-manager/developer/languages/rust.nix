{ pkgs, ... }:

{
  programs.cargo.enable = true;

  home.packages = with pkgs; [
    clippy
    rustc
    rust-analyzer
    rustfmt
  ];

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft = {
      rust = [ "rustfmt" ];
    };

    lsp.servers.rust_analyzer = {
      enable = true;
      installCargo = true;
      installRustc = true;
      installRustfmt = true;
    };
  };

  programs.zed-editor.extensions = [
    "rust"
  ];
}
