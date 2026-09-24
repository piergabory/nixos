{
  inputs,
  lib,
  isDroid ? false,
  ...
}:

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
      # Nixvim instantiates its own Nixpkgs from `nixpkgs.source`, so the
      # Nix-on-Droid overlay applied in `flake.nix` does not reach the plugins
      # it builds. See overlays/proot-unpack.nix.
      nixpkgs.overlays = lib.optionals isDroid [
        (import ../../../overlays/proot-unpack.nix)
      ];
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
