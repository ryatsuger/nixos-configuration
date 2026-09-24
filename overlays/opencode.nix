final: prev:
let
  version = "2.0.14";

  # Upstream publishes `-baseline` (pre-AVX2 x86_64) and `-musl` variants of each
  # package alongside these. The plain glibc builds are the right pick: they link
  # against nothing but glibc itself (libc/libm/libdl/libpthread — no libstdc++),
  # as do the native libraries bun unpacks at runtime, so autoPatchelfHook fixes
  # them up cleanly. The v1 overlay tracked the same non-baseline artifacts, and
  # this is the same treatment overlays/claude-code.nix gets.
  platforms = {
    "x86_64-linux" = {
      key = "linux-x64";
      hash = "sha256-o4JMwNCA/WnpXEeudRqLpJtmj2SS/P43f1yUHDN+U6k=";
    };
    "aarch64-linux" = {
      key = "linux-arm64";
      hash = "sha256-4PuS9EGRN5+rjMhpWVE9sJ5NSynn4mS87q7W32X2k+8=";
    };
  };
  plat = platforms.${prev.stdenv.hostPlatform.system};

  # Running opencode during the build needs three things neutralised: it writes
  # to $HOME, it would call the models.dev API, and the bun single-file runtime
  # unpacks itself under $TMPDIR/opencode — which in the sandbox is
  # /build/opencode, i.e. right on top of the extracted source, so it dies unless
  # pointed somewhere private.
  sandboxEnv = ''
    export HOME=$(mktemp -d)
    export TMPDIR=$(mktemp -d)
    export OPENCODE_DISABLE_MODELS_FETCH=true
  '';
in
{
  # nixos-26.05 pins opencode 1.15.10 and builds it from source via bun, which
  # also means every version bump waits on the channel. opencode releases several
  # times a day, so track the upstream prebuilt binary instead — same approach as
  # overlays/claude-code.nix and overlays/gws.nix.
  opencode = prev.stdenvNoCC.mkDerivation {
    pname = "opencode";
    inherit version;

    # v2 is not published as a GitHub release: the tags exist on the v2 branch but
    # carry no assets, and `https://opencode.ai/v2/install` resolves the current
    # version through https://opencode.ai/update/api/latest/cli/npm and then pulls
    # a per-platform npm package, so fetch the same tarball the installer does.
    # (The v1 line still ships GitHub release tarballs, which this overlay used
    # before.)
    src = prev.fetchurl {
      url = "https://registry.npmjs.org/@opencode/cli-${plat.key}/-/cli-${plat.key}-${version}.tgz";
      hash = plat.hash;
    };

    # Standard npm tarball layout: everything under package/, with the binary as
    # the sole payload at package/bin/opencode.
    sourceRoot = "package";

    dontBuild = true;
    dontStrip = true;

    nativeBuildInputs = [
      prev.autoPatchelfHook
      prev.installShellFiles
      prev.makeBinaryWrapper
    ];

    # Generating the completions means *running* opencode, which it cannot do
    # until its interpreter is rewritten. The automatic autoPatchelfHook fires
    # from postFixupHooks, i.e. after the `postFixup` variable, so driving it by
    # hand here is the only way to get the ordering right.
    dontAutoPatchelf = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 bin/opencode $out/bin/opencode
      autoPatchelf $out/bin

      wrapProgram $out/bin/opencode \
        --set OPENCODE_DISABLE_AUTOUPDATE 1 \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.ripgrep ]}

      ${sandboxEnv}

      # v2 replaced the `completion` subcommand with a --completions flag that
      # takes the dialect explicitly, so $SHELL no longer selects it. fish is a
      # supported dialect now too.
      installShellCompletion --cmd opencode \
        --bash <($out/bin/opencode --completions bash) \
        --zsh <($out/bin/opencode --completions zsh) \
        --fish <($out/bin/opencode --completions fish)

      runHook postInstall
    '';

    # Cheap sanity check that the patched binary actually executes on this host.
    doInstallCheck = true;
    installCheckPhase = ''
      ${sandboxEnv}

      $out/bin/opencode --version | grep -q "${version}"
    '';

    meta = {
      description = "AI coding agent built for the terminal";
      homepage = "https://github.com/anomalyco/opencode";
      license = prev.lib.licenses.mit;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
      mainProgram = "opencode";
      platforms = builtins.attrNames platforms;
    };
  };
}
