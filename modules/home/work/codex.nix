{ lib, stdenv, fetchurl, autoPatchelfHook, libgcc, zlib, openssl }:

let
  system = stdenv.hostPlatform.system;
  archMap = {
    "aarch64-linux" = "aarch64-unknown-linux-gnu";
    "x86_64-linux" = "x86_64-unknown-linux-gnu";
  };
  arch = archMap.${system} or (throw "Unsupported system: ${system}");
  
  sha256Map = {
    "aarch64-linux" = "0sah7c5id59miws802kp1rzwa25chjcnrxqqprla1x6zkbwygxwk";
    "x86_64-linux" = "01x418vvn0mgsj67k8qfng6sd83sq4ja6bn68r0494729lwfl15z";
  };
in
stdenv.mkDerivation rec {
  pname = "codex";
  version = "0.29.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${arch}.tar.gz";
    sha256 = sha256Map.${system};
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libgcc zlib openssl stdenv.cc.cc.lib ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    
    install -D -m755 codex-${arch} $out/bin/codex
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex - AI-powered code completion";
    homepage = "https://github.com/openai/codex";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" "x86_64-linux" ];
    maintainers = [ ];
  };
}