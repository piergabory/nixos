{ inputs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./keymaps.nix
    ./options.nix
    ./plugins.nix
  ];

  config = {
    programs.nixvim = {
      enable = true;
      nixpkgs.source = inputs.nixpkgs;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      clipboard.register = "unnamedplus";

      colorschemes.base16 = {
        enable = true;
        colorscheme = "gruvbox-dark-hard";
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      userCommands.Format.command = ''
        lua require('conform').format({
          async = true, lsp_format = 'fallback'
        })
      '';
    };
  };
}
