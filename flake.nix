{
  description = "AtCoder with Haskell";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      haskellNix,
      treefmt-nix,
      systems,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        overlays = [
          haskellNix.overlay
          (final: prev: {
            atcoderProject = final.haskell-nix.cabalProject' {
              src = ./.;
              # AtCoder uses GHC 9.8.4
              compiler-nix-name = "ghc984";
              shell = {
                tools = {
                  cabal = "latest";
                  hlint = "latest";
                  haskell-language-server = "latest";
                };
              };
            };
          })
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };
        flake = pkgs.atcoderProject.flake { };
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          programs = {
            cabal-fmt.enable = true;
            fourmolu.enable = true;
            nixfmt.enable = true;
          };
        };
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
      in
      flake
      // {
        legacyPackages = pkgs;

        packages = flake.packages // { };

        devShells = flake.devShells // {
          default = pkgs.mkShell {
            inputsFrom = [ flake.devShells.default ];
            packages = [
              atcoder-cli
              pkgs.online-judge-tools
              pkgs.online-judge-verify-helper
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
        };

        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      }
    );

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    allow-import-from-derivation = "true";
  };
}
