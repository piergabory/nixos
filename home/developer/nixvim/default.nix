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
  ] ++ lib.optionals (!isDroid) [
    ./plugins.nix
  ];

  config = {
    programs.nixvim = {
      enable = true;
      # Reuse the phone's already-overlaid package set instead of evaluating
      # a second Nixpkgs instance in the same memory-constrained process.
      nixpkgs.useGlobalPackages = isDroid;
      nixpkgs.source = lib.mkIf (!isDroid) inputs.nixpkgs;
      # The phone keeps Telescope and the Stylix/base16 theme only. Importing
      # the full plugin module pulls in hundreds of parser/plugin derivations.
      plugins.telescope.enable = lib.mkIf isDroid true;
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

      userCommands = lib.optionalAttrs (!isDroid) {
        Format.command = ''
          lua require('conform').format({
            async = true, lsp_format = 'fallback'
          })
        '';
      };
    };
  };
}
