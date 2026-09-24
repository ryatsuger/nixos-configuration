final: prev:
let
  version = "0.22.5";
  baseUrl = "https://github.com/googleworkspace/cli/releases/download/v${version}";

  # Upstream ships prebuilt Rust binaries. Prefer the *musl* artifacts: they are
  # fully statically linked, so they run on NixOS as-is with no autoPatchelfHook
  # and no interpreter rewriting (the gnu artifacts would need both).
  platforms = {
    "x86_64-linux" = {
      key = "x86_64-unknown-linux-musl";
      hash = "sha256-TbRz3eSxq4cuT/NddpsNSvHxpkQaYF551c+K2pyH6SA=";
    };
    "aarch64-linux" = {
      key = "aarch64-unknown-linux-musl";
      hash = "sha256-5wD+Y1JJMrEOwhMLR+zpCqhQ5mAF/lLM/Ez4dnv5kZo=";
    };
  };
  plat = platforms.${prev.stdenv.hostPlatform.system};
in
{
  # Google Workspace CLI. Not in nixpkgs; building from the upstream flake would
  # compile the whole Rust workspace from source on every channel bump, so track
  # the released binary instead — same approach as overlays/claude-code.nix.
  gws = prev.stdenvNoCC.mkDerivation {
    pname = "gws";
    inherit version;

    src = prev.fetchurl {
      url = "${baseUrl}/google-workspace-cli-${plat.key}.tar.gz";
      hash = plat.hash;
    };

    # The tarball has no single top-level directory — it unpacks gws, LICENSE
    # and the docs side by side — so point sourceRoot at the unpack dir itself.
    sourceRoot = ".";

    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 gws $out/bin/gws

      runHook postInstall
    '';

    # Cheap sanity check that the static binary actually executes on this host.
    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/gws --version | grep -q "${version}"
    '';

    meta = {
      description = "One CLI for all of Google Workspace, generated from the Discovery Service";
      homepage = "https://github.com/googleworkspace/cli";
      license = prev.lib.licenses.asl20;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
      mainProgram = "gws";
      platforms = builtins.attrNames platforms;
    };
  };
}
