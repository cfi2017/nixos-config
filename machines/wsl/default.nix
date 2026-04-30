{
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  wsl = {
    enable = true;
    defaultUser = "user";
  };

  networking = {
    hostName = "wsl";
    hostId = "12345678";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

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
        c = false;
        go = false;
        rust = false;
        k8s = true;
        iac = true;
        python = false;
        networking = false;
        security = false;
        infra = true;
        cloud = true;
        dev = false;
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
