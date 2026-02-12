{ pkgs, ... }:
{
  imports = [ ./sshd.nix ];
  services.usbmuxd.enable = true;
  services.pcscd.enable = true;
  services.fprintd.enable = true;
  services.printing.enable = true;
}
