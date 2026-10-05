{ pkgs, ... }: {
  cfi2017 = {
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    isLinux = pkgs.stdenv.hostPlatform.isLinux;
  };
}
