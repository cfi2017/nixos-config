{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./impermanence.nix
  ];

  networking = {
    hostName = "t14";
    hostId = "0014a14f";

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

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
