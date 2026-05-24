{ ... }:

{
  imports = [
    ./core.nix
    ./keymaps.nix
    ./lua.nix
    ./plugins/ai.nix
    ./plugins/completion.nix
    ./plugins/editor.nix
    ./plugins/formatting.nix
    ./plugins/lsp.nix
  ];

  stylix.targets.nixvim.enable = false;
}
