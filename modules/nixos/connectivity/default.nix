{ ... }: {
  imports = [ ./wireless.nix ];
  networking.networkmanager.enable = true;
}
