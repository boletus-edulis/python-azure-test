{
  lib,
  pythonPackages,
  src,
  azure-mgmt-resourcegraph,
}:

with pythonPackages;
buildPythonApplication {
  pname = "demo-flask-vuejs-rest";
  version = "1.0";

  propagatedBuildInputs = [
    azure-identity
    azure-mgmt-resourcegraph
  ];

  inherit src;
}
