# xgrammar 0.1.27 — structured output grammar engine (C++ extensions)
# Uses autoPatchelfHook for compiled shared objects.
{ python3, autoPatchelfHook, stdenv }:

python3.pkgs.buildPythonPackage rec {
  pname = "xgrammar";
  version = "0.1.27";
  format = "wheel";

  src = builtins.fetchurl {
    url = "https://files.pythonhosted.org/packages/48/74/70cfac0171d9f309cfe18c5384330e3edc9466c436b258495fd30ecf29a3/xgrammar-0.1.27-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    sha256 = "19bcbsjw001a5fajm95kynkhr5l2xv4cmwlnqh0l6m1g2a59hs7b";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib   # libstdc++
  ];

  propagatedBuildInputs = [
    python3.pkgs.torch
  ];

  pythonImportsCheck = [ "xgrammar" ];
}
