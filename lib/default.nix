{ lib, pkgs, ... }: {
  cfi2017 = {
    isDarwin = pkgs.stdenv.isDarwin;
    isLinux = pkgs.stdenv.isLinux;
  };
}
