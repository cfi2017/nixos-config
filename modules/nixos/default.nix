{ config, lib, ... }:
{
  imports = [
    ./desktop
    ./services
    ./storage
    ./system.nix
    ./utils
    ./virtualization
    ./network
  ];
}
