# Obsidian community plugins packaged from their GitHub release assets.
#
# The home-manager `programs.obsidian` module resolves a plugin's id from
# `pkg.manifestId` when present, otherwise it reads `manifest.json` out of the
# built derivation (import-from-derivation). Setting `passthru.manifestId`
# keeps evaluation IFD-free.
#
# To update a plugin: bump `version`/`baseUrl` and refresh the hashes with
#   nix-prefetch-url --type sha256 <url> | xargs nix hash convert --hash-algo sha256 --to sri
{ pkgs }:
let
  inherit (pkgs.lib) mapAttrsToList;

  mkObsidianPlugin =
    {
      id,
      version,
      baseUrl,
      files,
      meta ? { },
    }:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "obsidian-plugin-${id}";
      inherit version;

      srcs = mapAttrsToList (
        name: hash:
        pkgs.fetchurl {
          url = "${baseUrl}/${name}";
          inherit hash;
        }
      ) files;

      dontUnpack = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        for f in $srcs; do
          cp "$f" "$out/$(stripHash "$f")"
        done
        runHook postInstall
      '';

      passthru.manifestId = id;

      meta = {
        description = "Obsidian community plugin: ${id}";
        platforms = pkgs.lib.platforms.all;
      } // meta;
    };
in
{
  # https://github.com/husjon/obsidian-file-cleaner-redux
  file-cleaner-redux = mkObsidianPlugin {
    id = "file-cleaner-redux";
    version = "1.14.0";
    baseUrl = "https://github.com/husjon/obsidian-file-cleaner-redux/releases/download/1.14.0";
    files = {
      "main.js" = "sha256-BsoGd3+lV1TD2pfm/pBH1lTp/K/IOIsfMCY2fieduUU=";
      "manifest.json" = "sha256-/VgHXroi/ANbeH+VeFHiLLyo5AyeBZ7K6k7SpoUJEAU=";
    };
    meta.description = "Clean empty files and unused attachments in the vault";
  };

  # https://github.com/ryangomba/obsidian-todo-sort
  todo-sort = mkObsidianPlugin {
    id = "todo-sort";
    version = "1.0.2";
    baseUrl = "https://github.com/ryangomba/obsidian-todo-sort/releases/download/1.0.2";
    files = {
      "main.js" = "sha256-4NQfoFIV6n/SJuumSeMBkuhUT2ICtY2dZU49iEnDhIM=";
      "manifest.json" = "sha256-611YsTqs06Yr0urwwrEc5H8S+/jK6VMU09zg5bThcH0=";
    };
    meta.description = "Sort todos by completion status";
  };
}
