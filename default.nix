{ nixpkgs ? import <nixpkgs> {}
}:
let
  inherit (nixpkgs) pkgs;

  revealjs = pkgs.fetchFromGitHub {
    owner = "hakimel";
    repo = "reveal.js";
    rev = "a2e69a4b42f9e968406f62073d1c4bf0ea2d3361";
    sha256 = "0aclgbdb52zxhpzi9zvwxsx4qvvq2wy74bxm8l0lcj0csxqzrjm0";
  };

in
  pkgs.stdenv.mkDerivation {
    name = "snake-wrangling-talk";
    src = ./.;

    unpackPhase = ''
      mkdir -p $name/reveal.js
      cd $name
      cp -r ${revealjs}/* ./reveal.js/
      mkdir ./css
      cp -r ${revealjs}/lib/css/zenburn.css ./css/zenburn.css
      cp -r $src/img .
    '';

    buildPhase = ''

      cat $src/slides/title.md \
          $src/slides/motivation.md \
          $src/slides/design.md \
          $src/slides/propertytesting.md \
          $src/slides/cbc.md \
          $src/slides/concretesyntax.md \
          $src/slides/drawingboard.md \
          $src/slides/now.md \
          $src/slides/summary.md \
          > slides.md

      pandoc -t revealjs \
          --template=$src/template.revealjs \
          --variable=transition:none \
          --no-highlight \
          -s slides.md -o index.html

      rm slides.md
    '';

    installPhase = ''
      mkdir $out
      cp -r ./* $out/
    '';

    phases = ["unpackPhase" "buildPhase" "installPhase"];

    buildInputs = [pkgs.pandoc];
  }
