final: prev:
let
  version = "0.133.0";
  sources = {
    x86_64-linux = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-0GAZq5w10oG3jcLrsq5VwruX6hG/f0Urr+OQ7dsANO8=";
      binName = "codex-x86_64-unknown-linux-musl";
    };
    aarch64-linux = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-unknown-linux-musl.tar.gz";
      hash = "sha256-Jov+jPgVSUD+olbfdc1EHFSgxx5sjM1Fqz92/yi6FBM=";
      binName = "codex-aarch64-unknown-linux-musl";
    };
  };
  src = sources.${prev.stdenv.hostPlatform.system};
in
{
  # Replace codex with a prebuilt musl binary downloaded from the GitHub
  # release.  The upstream Rust workspace uses fat LTO + codegen-units=1
  # and pulls in V8, making a source build take 30+ minutes — the musl
  # binary is fully static and runs as-is on NixOS.
  codex = prev.stdenv.mkDerivation {
    pname = "codex";
    inherit version;

    src = prev.fetchurl {
      inherit (src) url hash;
    };

    sourceRoot = ".";
    dontUnpack = false;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;

    nativeBuildInputs = [ prev.makeBinaryWrapper ];

    installPhase = ''
      runHook preInstall
      install -Dm755 ${src.binName} $out/bin/.codex-unwrapped
      makeBinaryWrapper $out/bin/.codex-unwrapped $out/bin/codex \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.ripgrep ]}
      runHook postInstall
    '';

    meta = {
      description = "Lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      license = prev.lib.licenses.asl20;
      mainProgram = "codex";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  };
}
