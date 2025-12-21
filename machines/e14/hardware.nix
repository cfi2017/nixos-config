{
  pkgs,
  config,
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
      # timeout = 0;
    };
    initrd = {
      verbose = false;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ "virtio" ];
      luks.devices.cryptswap.device = "/dev/nvme0n1p3";
      systemd.enable = true;
    };
    kernelParams = [
      "mitigations=off"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    # deprecated
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    resumeDevice = "/dev/disk/by-label/swap";

    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    consoleLogLevel = 3;
  };

  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  services.xserver.xkb = {
    layout = "ch";
  };

  system = {
    stateVersion = "25.11";
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };
    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/nix/store" = {
      device = "rpool/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/cache" = {
      device = "rpool/local/cache";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/data" = {
      device = "rpool/safe/data";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
      open = true;
      modesetting = {
        enable = true;
      };
    };
  };
  services = {
    blueman.enable = true;
    fstrim.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia"
      "nvidia-settings"
      "ida-pro"
    ];
}
