final: prev:
let
  version = "0.156.1";
  baseUrl = "https://github.com/openai/codex/releases/download/rust-v${version}";
  platforms = {
    "x86_64-linux" = {
      key = "x86_64-unknown-linux-musl";
      hash = "sha256-r/RlOag6/4bjxixZK84sUNlTkfnfKJr68DpQwB0UUz0=";
      codeModeHostHash = "sha256-qSnaqfagvdwAwMnmQC3xF7ElrNlvnVVPbJnDLH5mxgg=";
    };
    "aarch64-linux" = {
      key = "aarch64-unknown-linux-musl";
      hash = "sha256-VY4SqqbayzNexHJAv5ch24pUdGgG1k8BGFpAP0T3m3I=";
      codeModeHostHash = "sha256-QBmBOLA3mP+owNpMgnqMpYlndOoQS3EQwqLAx1YMvpQ=";
    };
  };
  plat = platforms.${prev.stdenv.hostPlatform.system};
in
{
  # Replace codex with a prebuilt musl binary downloaded from the GitHub
  # release.  The upstream Rust workspace uses fat LTO + codegen-units=1
  # and pulls in V8, making a source build take 30+ minutes — the musl
  # binary is fully static and runs as-is on NixOS.
  codex = prev.stdenv.mkDerivation {
    pname = "codex";
    inherit version;

    # Upstream also ships a `codex-package-*` tarball bundling both binaries
    # plus its own rg/bwrap/zsh; take the two binaries we need on their own and
    # keep using nixpkgs' ripgrep.
    srcs = [
      (prev.fetchurl {
        url = "${baseUrl}/codex-${plat.key}.tar.gz";
        hash = plat.hash;
      })
      (prev.fetchurl {
        url = "${baseUrl}/codex-code-mode-host-${plat.key}.tar.gz";
        hash = plat.codeModeHostHash;
      })
    ];

    # Each tarball contains a single bare executable with no top-level
    # directory, so unpack both side by side in the build dir.
    sourceRoot = ".";

    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;

    nativeBuildInputs = [ prev.makeBinaryWrapper ];

    installPhase = ''
      runHook preInstall

      install -Dm755 codex-${plat.key} $out/bin/.codex-unwrapped
      makeBinaryWrapper $out/bin/.codex-unwrapped $out/bin/codex \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.ripgrep ]}

      # Code Mode (`features.code_mode`) spawns this helper by looking for it
      # next to the *running* executable — which is .codex-unwrapped, since the
      # wrapper execs it — so it has to sit in the same bin directory.
      install -Dm755 codex-code-mode-host-${plat.key} $out/bin/codex-code-mode-host

      runHook postInstall
    '';

    meta = {
      description = "Lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      license = prev.lib.licenses.asl20;
      mainProgram = "codex";
      platforms = builtins.attrNames platforms;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  };
}
