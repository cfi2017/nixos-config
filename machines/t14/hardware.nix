# This bootstrap-safe file is replaced with detected hardware configuration by
# the nixos-anywhere command documented in docs/onboarding-t14.md.
{
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      systemd.enable = true;
    };
  };

  console = {
    earlySetup = true;
    useXkbConfig = true;
  };
  services.xserver.xkb.layout = "ch";

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    graphics.enable = true;
  };

  services = {
    blueman.enable = true;
    fstrim.enable = true;
    tlp.enable = true;
    # The shared Hyprland module currently defaults to NVIDIA. Keep the
    # bootstrap configuration vendor-neutral until T14 hardware is detected.
    xserver.videoDrivers = lib.mkForce [ "modesetting" ];
  };

  hardware.nvidia.open = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.05";
}
