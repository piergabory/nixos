# Workaround for https://github.com/nix-community/nix-on-droid/issues/480
#
# nixpkgs' `_defaultUnpack` copies a directory `src` with `cp -r --preserve=...`,
# which creates the destination directory and then applies its mode with
# `fchmodat(..., AT_SYMLINK_NOFOLLOW)`. glibc >= 2.39 implements that with the
# `fchmodat2` syscall (Linux >= 6.6, i.e. Android 16), which proot does not know
# about and therefore never path-translates, so the call fails on a directory
# that does exist:
#
#   unpacking source archive /nix/store/...-source
#   cp: setting permissions for 'source': No such file or directory
#   do not know how to unpack source archive /nix/store/...-source
#
# See also https://github.com/proot-me/proot/issues/387. termux/proot still has
# no `fchmodat2` entry, so this cannot be fixed by bumping `proot-static`.
#
# Every package whose `src` is a directory (every `fetchFromGitHub` /
# `fetchgit`) is affected, but only once it has to be built on-device rather
# than substituted. The fix is to never let `cp` create the destination
# directory: pre-create it and copy the contents into it.
#
# Scope: the overlay only rewrites the derivations selected by `needsFix`, so
# every other package keeps its upstream store path and stays substitutable
# from cache.nixos.org. Patching indiscriminately would change every hash in
# nixpkgs and force the phone to compile the whole world.
#
# The selected sets are the ones this configuration actually has to build
# locally, determined by dry-running the activation package:
#
#   * `termux-am` / `termux-tools` — nix-on-droid's own packages, pulled in by
#     `android-integration.*.enable`, present in no binary cache.
#   * `vimPlugins` — the nixvim/stylix plugins; `vimPlugins` is largely
#     unbuilt for aarch64-linux on Hydra.
#
# If another package ever has to be compiled on-device and fails the same way,
# add its `name`/`pname` to `namesToFix` below.
#
# This overlay has to be wired in twice:
#
#   1. `flake.nix`, through the `pkgs` argument of `nixOnDroidConfiguration`.
#   2. `home/developer/nixvim/default.nix`, through
#      `programs.nixvim.nixpkgs.overlays` — nixvim instantiates its own Nixpkgs
#      from `nixpkgs.source`, so the first one does not reach its plugins.
#
# The build set can be checked without a phone: evaluate the configuration with
# `user.uid`/`user.gid` set explicitly (that avoids the aarch64 `ids.nix`
# import-from-derivation) and run
# `nix-store --realise --dry-run <nix-on-droid-generation.drv>`.
let
  namesToFix = [
    "termux-am"
    "termux-tools"
  ];

  # `--no-preserve=mode` is what stops `cp` from chmod-ing the directories it
  # creates; the executable bits it drops are restored from the source tree
  # afterwards. `chmod` on an existing file resolves to the plain `fchmodat`
  # syscall, which proot does handle.
  prootUnpack = ''
    _defaultUnpack() {
      local fn="$1"
      if [ -d "$fn" ]; then
        local destDir
        destDir="$(stripHash "$fn")"
        mkdir -p "$destDir"
        cp -r --no-preserve=mode,ownership -- "$fn"/. "$destDir"/
        chmod -R u+w "$destDir"
        ( cd "$fn" && find . -type f -perm -u+x -print0 ) \
          | ( cd "$destDir" && xargs -0 -r chmod +x -- )
      else
        case "$fn" in
          *.tar.xz | *.tar.lzma | *.txz) xz -d < "$fn" | tar xf - --warning=no-timestamp ;;
          *.tar.gz | *.tgz | *.tar.Z) gzip -d < "$fn" | tar xf - --warning=no-timestamp ;;
          *.tar.bz2 | *.tbz2 | *.tbz) bzip2 -d < "$fn" | tar xf - --warning=no-timestamp ;;
          *.tar.zst) zstd -d < "$fn" | tar xf - --warning=no-timestamp ;;
          *.tar) tar xf "$fn" --warning=no-timestamp ;;
          *) return 1 ;;
        esac
      fi
    }
  '';

  needsFix =
    args: builtins.elem (args.name or "") namesToFix || builtins.elem (args.pname or "") namesToFix;

  fixArgs =
    args: if needsFix args then args // { preUnpack = (args.preUnpack or "") + prootUnpack; } else args;

  applyToDrv =
    drv:
    drv.overrideAttrs (old: {
      preUnpack = (old.preUnpack or "") + prootUnpack;
    });

  # `//` leaves the stdenv derivation itself untouched, and `fixArgs` is the
  # identity for everything that is not selected, so unselected derivations
  # keep byte-identical store paths.
  wrapStdenv =
    stdenv:
    stdenv
    // {
      # Only the plain attribute-set form is rewritten. Forcing the result of
      # the `finalAttrs:` form here would evaluate it inside its own fixed
      # point and cause an infinite recursion.
      mkDerivation =
        arg: if builtins.isAttrs arg then stdenv.mkDerivation (fixArgs arg) else stdenv.mkDerivation arg;
    };
in
_final: prev: {
  stdenv = wrapStdenv prev.stdenv;
  stdenvNoCC = wrapStdenv prev.stdenvNoCC;

  # `buildVimPlugin` uses the `finalAttrs:` form of `mkDerivation`, which the
  # wrapper above cannot inspect, so the plugins are patched through their own
  # scope instead. Rewriting all of them is cheap here: Hydra builds almost no
  # `vimPlugins` for aarch64-linux, so they are compiled on-device regardless.
  vimPlugins = prev.vimPlugins.extend (
    _finalScope: prevScope:
    builtins.mapAttrs (
      _name: value: if prev.lib.isDerivation value then applyToDrv value else value
    ) prevScope
  );
}
