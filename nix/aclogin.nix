{ pkgs }:
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
}
