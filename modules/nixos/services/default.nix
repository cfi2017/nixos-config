{ pkgs, ... }:
{
  imports = [ ./sshd.nix ];
  services.usbmuxd.enable = true;
  services.pcscd.enable = false;
  services.fprintd.enable = true;
  services.printing.enable = true;
  services.hardware.bolt.enable = true;
}
