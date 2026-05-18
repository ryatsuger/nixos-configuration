final: prev:
let
  version = "2.1.141";
  baseUrl = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
  platforms = {
    "x86_64-linux" = {
      key = "linux-x64";
      hash = "sha256-gyvibo8Vsq6Z5SCiKwNPxL+tHLW4Tea3BkhwcsVrtC4=";
    };
    "aarch64-linux" = {
      key = "linux-arm64";
      hash = "sha256-3JMeJPYq+63I3GgRUniwhJOCWj7R6nU9WHB3GBpsxjs=";
    };
  };
  plat = platforms.${prev.stdenv.hostPlatform.system};
in
{
  # Upstream claude-code switched from npm-distributed source to a single
  # prebuilt binary (bun-compiled). Replace it with the binary distribution
  # rather than overrideAttrs on the old npm derivation, which no longer
  # matches the upstream package shape.
  claude-code = prev.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    inherit version;

    src = prev.fetchurl {
      url = "${baseUrl}/${version}/${plat.key}/claude";
      hash = plat.hash;
    };

    dontUnpack = true;
    dontBuild = true;
    dontStrip = true;

    nativeBuildInputs = [
      prev.installShellFiles
      prev.makeBinaryWrapper
      prev.autoPatchelfHook
    ];

    installPhase = ''
      runHook preInstall

      installBin $src

      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        --prefix PATH : ${prev.lib.makeBinPath [
          prev.procps
          prev.ripgrep
          prev.bubblewrap
          prev.socat
        ]}

      runHook postInstall
    '';

    meta = {
      description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
      homepage = "https://github.com/anthropics/claude-code";
      license = prev.lib.licenses.unfree;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
      mainProgram = "claude";
      platforms = builtins.attrNames platforms;
    };
  };
}
