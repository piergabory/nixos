{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
  makeBinaryWrapper,
  ripgrep,
  wayland,
}:

# Use the upstream release on the phone: the source package's Bun dependency
# build includes desktop/app workspaces and is unsuitable for local PRoot builds.
stdenvNoCC.mkDerivation rec {
  pname = "opencode-droid";
  version = "2.2.6";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
    # Verified against the release's SHA256SUMS and GitHub asset digest.
    hash = "sha256-8tJ2AMNn5FBX1qFvalwqqNd7QamxDUvD2EnC+Ihw6UQ=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ patchelf makeBinaryWrapper ];
  dontConfigure = true;
  dontBuild = true;
  # Only change the interpreter. With this upstream ARM64 executable,
  # patchelf 0.15.2 --set-rpath relocates the dynamic section and the loader
  # segfaults before main(). Supply dlopen paths through the wrapper instead.
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode "$out/bin/opencode"
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$out/bin/opencode"
    wrapProgram "$out/bin/opencode" \
      --set OPENCODE_DISABLE_AUTOUPDATE true \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc wayland ]} \
      --suffix PATH : ${lib.makeBinPath [ ripgrep ]}
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    testHome=$(mktemp -d)
    mkdir -p "$testHome/tmp"
    actual=$(HOME="$testHome" TMPDIR="$testHome/tmp" \
      XDG_CONFIG_HOME="$testHome/config" XDG_CACHE_HOME="$testHome/cache" \
      XDG_DATA_HOME="$testHome/data" XDG_STATE_HOME="$testHome/state" \
      OPENCODE_DISABLE_MODELS_FETCH=true "$out/bin/opencode" --version)
    test "$actual" = "opencode v${version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "OpenCode official ARM64 CLI release, repackaged for Nix-on-Droid";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-linux" ];
    mainProgram = "opencode";
  };
}
