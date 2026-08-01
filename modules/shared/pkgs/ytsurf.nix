{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  bash,
  chafa,
  coreutils,
  curl,
  ffmpeg,
  findutils,
  fzf,
  jq,
  mpv,
  perl,
  yt-dlp,
}:

let
  version = "3.1.5";
  src = fetchFromGitHub {
    owner = "Stan-breaks";
    repo = "ytsurf";
    rev = "5fb63cfce31eebda45c6775f8ebdaec242339b61";
    sha256 = "09741hw7ampdd62hi0fwvm1pvra2y2aswsrpvafvn5wsxzr60z7k";
  };
in
stdenvNoCC.mkDerivation {
  pname = "ytsurf";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src/ytsurf.sh $out/bin/ytsurf
    wrapProgram $out/bin/ytsurf \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          chafa
          coreutils
          curl
          ffmpeg
          findutils
          fzf
          jq
          mpv
          perl
          yt-dlp
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "YouTube in your terminal";
    homepage = "https://github.com/Stan-breaks/ytsurf";
    license = lib.licenses.gpl3Only;
    mainProgram = "ytsurf";
    platforms = lib.platforms.unix;
  };
}
