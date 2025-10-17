{ lib, pkgs, ... }: {
  config-flake = {
    isDarwin = pkgs.stdenv.isDarwin;
    isLinux = pkgs.stdenv.isLinux;
  };
}
