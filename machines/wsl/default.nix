{ ... }:
{
  # imports = [ ./hardware.nix ];

  cfi2017 = {
    stateVersion = "25.05";
    gpg.enable = true;
    persistence.enable = false;
    core = {
      zfs = {
        enable = false;
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
        docker.enable = false;
        hypervisor.enable = false;
      };
    };
    graphical = {
      enable = false;
    };
  };
}
