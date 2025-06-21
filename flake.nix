{
    description = "SF Mono patched with Nerd Font symbols";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };
                inherit (pkgs) stdenv lib nerd-font-patcher;

                fontFiles = builtins.attrNames (builtins.readDir ./fonts);
                fontPaths = map (f: ./fonts + "/${f}") fontFiles;

                patchedFonts = map (fontFile:
                    let
                        fontName = lib.removeSuffix ".otf" (baseNameOf fontFile);
                    in
                    stdenv.mkDerivation {
                        pname = "${fontName}-NerdFont";
                        version = "1.0";
                        src = fontFile;
                        nativeBuildInputs = [ nerd-font-patcher ];

                        unpackPhase = ''
                            cp $src ${fontName}.otf
                        '';

                        buildPhase = ''
                            nerd-font-patcher ${fontName}.otf --complete --outputdir .
                        '';

                        installPhase = ''
                            runHook preInstall
                            # install -Dm644 *.otf -t $out/share/fonts/opentype/
                            find . -name "*.otf" -name "*Nerd*" -exec install -Dm644 {} -t $out/ \;
                            runHook postInstall
                        '';

                        dontFixup = true;
                    }
                ) fontPaths;
            in {
                packages.default = pkgs.symlinkJoin {
                    name = "sf-mono-nerd-font-complete";
                    paths = patchedFonts;
                };
            });
}
