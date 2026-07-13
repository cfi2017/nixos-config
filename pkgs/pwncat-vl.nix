{
  lib,
  python3Packages,
}:
# pwncat-vl: community-maintained fork of Caleb Stewart's pwncat post-exploitation
# platform, kept alive for Python 3.13+. Not in nixpkgs, so we build it from the
# PyPI sdist. Upstream pins fork variants (paramiko-ng, ZODB3) and pre-3.13
# version bounds, but the code actually imports plain `paramiko`, `ZODB` and
# `persistent` -- all provided by nixpkgs' paramiko + zodb -- so we relax the
# version bounds and skip the dist-name runtime check that would otherwise insist
# on the fork package names.
python3Packages.buildPythonApplication rec {
  pname = "pwncat-vl";
  version = "0.7.0";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "pwncat_vl";
    inherit version;
    hash = "sha256-07n9vxTVEqabYKpR1Dhh4FMdbctfmpT/ibqrpq5R5Rk=";
  };

  build-system = [ python3Packages.poetry-core ];

  pythonRelaxDeps = true;
  dontCheckRuntimeDeps = true;

  dependencies = with python3Packages; [
    jinja2
    zodb
    cryptography
    libpass
    packaging
    paramiko
    prompt-toolkit
    psutil
    pygments
    requests
    rich
  ];

  pythonImportsCheck = [ "pwncat" ];

  # No test suite is shipped in the sdist; this is a CTF/pentest tool.
  doCheck = false;

  meta = {
    description = "Community-maintained fork of pwncat (post-exploitation platform) with Python 3.13+ support";
    homepage = "https://github.com/Chocapikk/pwncat-vl";
    license = lib.licenses.mit;
    mainProgram = "pwncat-vl";
  };
}
