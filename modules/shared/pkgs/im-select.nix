{
  lib,
  stdenv,
  fetchurl,
  clang,
  apple-sdk_15,
}:

stdenv.mkDerivation {
  pname = "im-select";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/daipeihust/im-select/archive/refs/tags/1.0.1.tar.gz";
    hash = "sha256-4kzdt44Luxs/nbPxVa6pCDgQCMwCEHnU1n+6okz6/L8=";
  };

  sourceRoot = "im-select-1.0.1";
  nativeBuildInputs = [ clang ];
  buildInputs = [ apple-sdk_15 ];

  buildPhase = ''
    runHook preBuild
    clang im-select-mac/im-select/im-select/main.m \
      -framework Foundation \
      -framework Carbon \
      -o im-select
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp im-select $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "Command-line macOS input source switcher";
    homepage = "https://github.com/daipeihust/im-select";
    license = lib.licenses.mit;
    mainProgram = "im-select";
    platforms = lib.platforms.darwin;
  };
}
