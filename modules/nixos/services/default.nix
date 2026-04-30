{ pkgs, ... }:
{
  imports = [ ./sshd.nix ];
  services.usbmuxd.enable = true;
  services.pcscd.enable = false;
  services.fprintd.enable = true;
  services.fprintd.tod = {
    enable = true;
    driver = pkgs.libfprint-2-tod1-goodix-550a;
  };
  services.printing.enable = true;
  services.hardware.bolt.enable = true;
}
