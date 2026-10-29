{ lib, pkgs, ... }:
with lib;

{
  home.packages = with pkgs; [
    nix
    nixd
    nixfmt
    nix-doc
    nix-btm
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
      nixd.enable = true;
    };
  };

  programs.zed-editor = {
    userSettings = {
      languages = {
        "Nix" = {
          language_servers = [
            "nixd"
          ];
        };
      };
      lsp = {
        nixd.binary.path = getExe pkgs.nixd;
      };
    };
    extensions = [
      "nix"
    ];
  };
}
