{ inputs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./extraConfigLua.nix
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
      colorscheme = "retrobox";

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

    stylix.targets.nixvim.enable = false;
  };
}
