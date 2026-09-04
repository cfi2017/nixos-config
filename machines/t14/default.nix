{ lib, ... }:
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./impermanence.nix
  ];

  virtualisation.docker.storageDriver = "btrfs";

  networking = {
    hostName = "t14";
    hostId = "0014a14f";

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd.enable = true;
  };

  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    graphics.enable = true;
    # The shared Hyprland module currently defaults to NVIDIA. Keep enrollment
    # vendor-neutral until the generated hardware configuration is reviewed.
    nvidia.open = false;
  };

  services = {
    blueman.enable = true;
    fstrim.enable = true;
    tlp.enable = true;
    xserver = {
      videoDrivers = lib.mkForce [ "modesetting" ];
      xkb.layout = "ch";
    };
  };

  system.stateVersion = "26.05";

  cfi2017 = {
    stateVersion = "26.05";
    gpg.enable = true;
    persistence.enable = true;
    core.zfs.enable = false;
    development-packages = {
      enable = true;
      tools = {
        c = true;
        go = true;
        rust = true;
        k8s = true;
        iac = true;
        python = true;
        networking = true;
        security = true;
        infra = true;
        cloud = true;
        dev = true;
      };
    };
    development.virtualisation = {
      docker.enable = true;
      hypervisor.enable = true;
    };
    graphical = {
      enable = true;
      laptop = true;
      hyprland.enable = true;
      xdg.enable = true;
    };
  };
}
