{ inputs, pkgs, ... }:

{
  programs.zen-browser.profiles.default.extensions.packages =
    with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      ublock-origin
      bitwarden
      sponsorblock
      darkreader
    ];
}
