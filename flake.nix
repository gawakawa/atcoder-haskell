{
    # ref: https://github.com/toyboot4e/abc-hs/blob/main/flake.nix
    description = "AtCoder with Haskell";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
        in
        {
            devShells.default = with pkgs; mkShell {
                nativeBuildInputs = [
                    pkg-config
                    stack
                    cabal-install
                    llvmPackages.bintools
                ];

                packages = [
                    # atcoder-cli is from npm

                    online-judge-tools
                    nodejs
                    hlint

                    # lts-21.6
                    haskell.compiler.ghc946
                    (haskell-language-server.override { supportedGhcVersions = [ "946" ]; })

                    # lts-21.15
                    # haskell.compiler.ghc947
                    # (haskell-language-server.override { supportedGhcVersions = [ "947" ]; })

                    # lts-22.0
                    # haskell.compiler.ghc963
                    # (haskell-language-server.override { supportedGhcVersions = [ "963" ]; })
                    haskellPackages.hoogle
                    haskellPackages.ghcid
                    haskellPackages.ghcide
                    haskellPackages.ghci-dap
                    haskellPackages.haskell-dap
                    haskellPackages.haskell-debug-adapter
                ];

                shellHook = ''
                    export PATH=$PATH:"./node_modules/.bin"

                    # If atcoder-cli is not installed, install it and login
                    command -v acc &> /dev/null || (npm install atcoder-cli && acc login)

                    # If acc-config is not linked, link it
                    [ -L "$(acc config-dir)/haskell" ] || (mkdir -p "$(acc config-dir)/haskell" && ln -s "$PWD/acc-config" "$ACC_CONFIG_PATH")

                    acc config oj-path $(which oj)
                '';
            };
        }
    );
}