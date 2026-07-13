{ pkgs, ... }:
{
  pwncat-vl = pkgs.callPackage ./pwncat-vl.nix { };
}
