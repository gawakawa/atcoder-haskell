{
  description = "AtCoder with Haskell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        atcoder-cli = pkgs.stdenv.mkDerivation {
          pname = "atcoder-cli";
          version = "2.2.0";

          dontUnpack = true;

          buildInputs = [
            pkgs.cacert
            pkgs.nodejs_22
          ];

          buildPhase = ''
            export HOME=$TMPDIR
            export NODE_OPTIONS="--openssl-legacy-provider"
            export npm_config_cafile=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

            mkdir -p npm_packages

            ${pkgs.nodejs_22}/bin/npm install atcoder-cli@2.2.0 --prefix=$PWD/npm_packages --legacy-peer-deps --no-optional --unsafe-perm
          '';

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/lib

            cp -r npm_packages/node_modules $out/lib/

            cat > $out/bin/acc << EOF
            #!/bin/sh
            export NODE_OPTIONS="--openssl-legacy-provider"
            export NODE_PATH=$out/lib
            exec ${pkgs.nodejs_22}/bin/node $out/lib/node_modules/atcoder-cli/bin/index.js "\$@"
            EOF
            chmod +x $out/bin/acc
          '';
        };

        oj-verify =
          with pkgs.python3Packages;
          pkgs.python3Packages.buildPythonApplication {
            name = "verification-helper";
            version = "5.6.0";
            pyproject = true;
            src = pkgs.fetchFromGitHub {
              owner = "online-judge-tools";
              repo = "verification-helper";
              rev = "adbff121b1f96de5f34e9f1483eb47d661c54075";
              fetchSubmodules = false;
              sha256 = "sha256-f7Ge8kLRQv9uxdNGtgNsypGVY0XAnKPCg8HYQ5nT6mI=";
            };
            build-system = [ setuptools ];
            dependencies = [
              colorlog
              importlab
              online-judge-tools
              pyyaml
              setuptools
              toml
            ];
            propagatedBuildInputs = [ setuptools ];
          };

        aclogin =
          with pkgs.python3Packages;
          pkgs.python3Packages.buildPythonApplication {
            name = "aclogin";
            version = "0.0.1";
            format = "setuptools";
            # doCheck = false;
            src = pkgs.fetchFromGitHub {
              owner = "key-moon";
              repo = "aclogin";
              rev = "e461311c0326578b16d1488be84261f4b24f6134";
              fetchSubmodules = false;
              sha256 = "sha256-kyU7KpFenFb7obwSrDp6dPfuE+36r0BGYerrJj3+EyA=";
            };
            dependencies = [
              appdirs
              requests
            ];
            propagatedBuildInputs = [ setuptools ];
          };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              cabal-install
              llvmPackages.bintools
              pkg-config
              stack
            ];

            packages = [
              aclogin
              atcoder-cli
              oj-verify
              online-judge-tools

              haskell.compiler.ghc965
              haskellPackages.cabal-fmt
              haskellPackages.doctest
              haskellPackages.fourmolu
              haskellPackages.ghci-dap
              haskellPackages.ghcid
              haskellPackages.ghcide
              haskellPackages.haskell-dap
              haskellPackages.haskell-debug-adapter
              haskellPackages.haskell-language-server
              haskellPackages.hoogle
              haskellPackages.implicit-hie
              hlint
            ];

            shellHook = ''
              acc config oj-path $(which oj)
              export ROOT="$PWD"

              alias t='$ROOT/test.sh $(basename $PWD)'
              alias s='acc s'
              alias ts='t && s'

              new() {
                  $ROOT/new.sh $1
              }
            '';
          };
      }
    );
}
