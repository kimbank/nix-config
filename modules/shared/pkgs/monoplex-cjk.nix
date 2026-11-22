{ lib, stdenvNoCC, fetchurl, unzip }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "monoplex-cjk";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/y-kim/monoplex/releases/download/monoplex-cjk-${finalAttrs.version}/MonoplexCJK_v${finalAttrs.version}.zip";
    hash = "sha256-fUirRkdbS2MPBleYmaOFFAo1olv1EG7rldLH51L16wY=";
  };

  nativeBuildInputs = [ unzip ];
  installPhase = ''
    runHook preInstall
    install -Dm444 -t "$out/share/fonts/truetype/monoplex-cjk" *.ttf
    install -Dm444 LICENSE.md "$out/share/licenses/monoplex-cjk/LICENSE.md"
    runHook postInstall
  '';

  meta = {
    description = "Monospace IBM Plex family for Latin, Hangul, kana, and Han characters";
    homepage = "https://github.com/y-kim/monoplex";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
