{ ... }:
{
  imports = [ ./hardware.nix ];

  networking = {
    hostName = "t490s";
    hostId = "00000002";

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

  };

  cfi2017 = {
    stateVersion = "25.05";
    gpg.enable = true;
    persistence.enable = true;
    core = {
      zfs = {
        enable = true;
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
    };
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
    development = {
      virtualisation = {
        docker.enable = true;
        hypervisor.enable = true;
      };
    };
    graphical = {
      enable = true;
      laptop = true;
      hyprland = {
        enable = true;
      };
      xdg = {
        enable = true;
      };
    };
  };
}