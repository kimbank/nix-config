final: _prev:

let
  version = "3.1.5";
  src = final.fetchFromGitHub {
    owner = "Stan-breaks";
    repo = "ytsurf";
    rev = "5fb63cfce31eebda45c6775f8ebdaec242339b61";
    sha256 = "09741hw7ampdd62hi0fwvm1pvra2y2aswsrpvafvn5wsxzr60z7k";
  };
in
{
  ytsurf = final.stdenvNoCC.mkDerivation {
    pname = "ytsurf";
    inherit version src;

    nativeBuildInputs = [ final.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 $src/ytsurf.sh $out/bin/ytsurf
      wrapProgram $out/bin/ytsurf \
        --prefix PATH : ${
          final.lib.makeBinPath [
            final.bash
            final.chafa
            final.coreutils
            final.curl
            final.ffmpeg
            final.findutils
            final.fzf
            final.jq
            final.mpv
            final.perl
            final.yt-dlp
          ]
        }

      runHook postInstall
    '';

    meta = with final.lib; {
      description = "YouTube in your terminal";
      homepage = "https://github.com/Stan-breaks/ytsurf";
      license = licenses.gpl3Only;
      mainProgram = "ytsurf";
      platforms = platforms.unix;
    };
  };
}
