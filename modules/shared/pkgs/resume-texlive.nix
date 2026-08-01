{ texliveSmall }:

texliveSmall.withPackages (
  ps: with ps; [
    latexmk
    collection-langkorean
    fontspec
    luatexko
    polyglossia
    titlesec
    marvosym
    enumitem
    pgf
    preprint
  ]
)
