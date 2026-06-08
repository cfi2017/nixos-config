{ pkgs, ... }:
{
  imports = [ ./sshd.nix ];
  services.usbmuxd.enable = true;
  services.pcscd.enable = true;
  # prevent yubikey locking when pcscd is enabled
  services.udev.extraRules = ''
    # YubiKey 5 NFC / 5C NFC
    ATTR{idVendor}=="1050", ATTR{idProduct}=="0407", ENV{ID_SMARTCARD_READER}="", ENV{ID_SMARTCARD_READER_DRIVER}=""
    # YubiKey 5C
    ATTR{idVendor}=="1050", ATTR{idProduct}=="0406", ENV{ID_SMARTCARD_READER}="", ENV{ID_SMARTCARD_READER_DRIVER}=""
  '';
  services.fprintd.enable = true;
  services.fprintd.tod = {
    enable = true;
    driver = pkgs.libfprint-2-tod1-goodix-550a;
  };
  services.printing.enable = true;
  services.hardware.bolt.enable = true;
}
