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

        aclogin =
          with pkgs.python3Packages;
          pkgs.python3Packages.buildPythonApplication {
            name = "aclogin";
            version = "0.0.1";
            format = "setuptools";
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

        # Helper function to create wrapped scripts
        mkWrappedScript =
          name: scriptPath: deps:
          let
            script = (pkgs.writeScriptBin "${name}.sh" (builtins.readFile scriptPath)).overrideAttrs (old: {
              buildCommand = "${old.buildCommand}\n patchShebangs $out";
            });
          in
          pkgs.symlinkJoin {
            inherit name;
            paths = [ script ] ++ deps;
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = "wrapProgram $out/bin/${name}.sh --prefix PATH : $out/bin";
          };

        # Script wrappers
        new-wrapped = mkWrappedScript "new" ./scripts/new.sh [
          atcoder-cli
          pkgs.online-judge-tools
          pkgs.jq
          pkgs.git
        ];

        test-wrapped = mkWrappedScript "test" ./scripts/test.sh [
          pkgs.online-judge-tools
        ];

        run-wrapped = mkWrappedScript "run" ./scripts/run.sh [ ];
      in
      flake
      // {
        legacyPackages = pkgs;

        packages = flake.packages // { };

        devShells = flake.devShells // {
          default = pkgs.mkShell {
            inputsFrom = [ flake.devShells.default ];
            packages = [
              aclogin
              atcoder-cli
              pkgs.online-judge-tools
              pkgs.online-judge-verify-helper
              new-wrapped
              test-wrapped
              run-wrapped
            ];
            shellHook = ''
              export ROOT="$PWD"
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
