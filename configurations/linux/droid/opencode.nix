{
  config,
  lib,
  pkgs,
  ...
}:

{
  # This directory precedes the Nix profile in the phone's PATH.
  home.file.".local/bin/opencode".source = "${config.programs.opencode.package}/bin/opencode";

  programs.opencode = {
    package = pkgs.callPackage ./opencode-package.nix { };
    # The pinned Stylix target uses the OpenCode 1 option; OpenCode 2 uses cli.json.
    tui = lib.mkForce { };
    cli.theme = "stylix";
  };
}
