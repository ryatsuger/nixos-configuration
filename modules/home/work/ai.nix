{ config, lib, pkgs, ... }:

let
  claudeVersion = "1.0.88";
  claudeCode_latest = pkgs.claude-code.overrideAttrs (old: {
    version = claudeVersion;

    # fetch the exact tarball from npm
    src = pkgs.fetchurl {
      url =
        "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claudeVersion}.tgz";
      # run the command below and paste the result:
      hash = "sha256-w5moh5uANkylnFuLiHKRMpfC4v0eCy+dwxSe3glDbnQ=";
    };

    # update the vendor-deps hash (required for all npm-builds)
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  });

  geminiVersion = "0.1.12";
  gemini_latest = pkgs.gemini-cli.overrideAttrs (old: {
    version = geminiVersion;
    src = pkgs.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = "d1596cedadae4306adc4bd073daf645fe1327fd7";
      hash = "sha256-2w28N6Fhm6k3wdTYtKH4uLPBIOdELd/aRFDs8UMWMmU=";
    };

    # update the vendor-deps hash (required for all npm-builds)
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  });

  codex = pkgs.callPackage ./codex.nix {};
in {
  # nixpkgs.config.allowUnfree = true;  # This is already set globally
  home.packages = [
    claudeCode_latest
    gemini_latest
    #pkgs.gemini-cli
    codex
  ];
}
