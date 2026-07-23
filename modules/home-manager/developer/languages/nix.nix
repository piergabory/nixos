{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nix
    nixd
    nixfmt
    nix-doc
    nix-btm
    nix-top
    nix-tree
    nix-health
    nix-output-monitor
  ];

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nixvim.plugins = {
    conform-nvim.settings.formatters_by_ft = {
      nix = [ "nixfmt" ];
    };

    lsp.servers = {
      nil_ls.enable = true;
      nixd.enable = true;
    };
  };

  programs.zed-editor.extensions = [
    "nix"
  ];
}
