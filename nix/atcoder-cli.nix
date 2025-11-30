{ pkgs }:
pkgs.buildNpmPackage {
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
}
