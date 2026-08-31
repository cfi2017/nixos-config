{ pkgs, ... }:
{
  attachment-open = pkgs.callPackage ./attachment-open.nix { };
  pwncat-vl = pkgs.callPackage ./pwncat-vl.nix { };
}
