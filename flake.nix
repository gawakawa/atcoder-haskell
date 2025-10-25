{
  description = "AtCoder with Haskell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { system, pkgs, ... }:
        let
          atcoder-cli = pkgs.buildNpmPackage {
            pname = "atcoder-cli";
            version = "2.2.0";

            src = pkgs.fetchFromGitHub {
              owner = "Tatamo";
              repo = "atcoder-cli";
              rev = "v2.2.0";
              hash = "sha256-7pbCTgWt+khKVyMV03HanvuOX2uAC0PL9OLmqly7IWE=";
            };

            npmDepsHash = "sha256-ufG7Fq5D2SOzUp8KYRYUB5tYJYoADuhK+2zDfG0a3ks=";

            nativeBuildInputs = [ pkgs.nodejs_20 ];

            NODE_OPTIONS = "--openssl-legacy-provider";

            dontNpmBuild = true;
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
                atcoder-cli
                oj-verify
                online-judge-tools

                haskell.compiler.ghc984
                haskellPackages.cabal-fmt
                haskellPackages.doctest
                haskellPackages.ghcid
                haskellPackages.ghcide
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

          treefmt = {
            programs = {
              nixfmt.enable = true;
              fourmolu.enable = true;
              cabal-fmt.enable = true;
            };
          };
        };
    };
}
