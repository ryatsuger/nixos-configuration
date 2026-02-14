{ config, lib, pkgs, ... }:

let
  claudeVersion = "2.1.34";
  claudeCode_latest = pkgs.claude-code.overrideAttrs (old: {
    version = claudeVersion;

    # fetch the exact tarball from npm
    src = pkgs.fetchurl {
      url =
        "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claudeVersion}.tgz";
      hash = "sha256-9poksTheZl3zwxmGwTNwAmUmTooZCY5huFqe73RYh1A=";
    };

    npmDepsHash = "sha256-n762einDxLUUXWMsfdPVhA/kn0ywlJgFQ2ZGoEk3E68=";
  });

  geminiVersion = "v0.20.0-nightly.20251202.29920b16d";
  gemini_latest = pkgs.gemini-cli.overrideAttrs (old: let
    src = pkgs.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = geminiVersion;
      hash = "sha256-lNz7t88KZt8dNm9S+LfiSOXSmjBKaZ+hBzlrpeeTyoc=";

    };
  in {
    inherit src;
    version = geminiVersion;
    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      hash = "sha256-us8afDtl6kiURsYJj/3wNgnybei3x6K8jbNMMO2WDGk=";
    };
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.libsecret ];
    postInstall = (old.postInstall or "") + ''
      rm -rf $out/lib/packages
      cp -r packages $out/lib/
    '';
  });

  codex = pkgs.callPackage ./codex.nix { };
in {
  # nixpkgs.config.allowUnfree = true;  # This is already set globally
  home.packages = [
    claudeCode_latest
    pkgs.obsidian
    gemini_latest
    #pkgs.gemini-cli
    codex
  ];
}
