{ ... }: {
  imports = [ ./hardware.nix ];

  networking = {
    hostName = "e14";

    nameservers = [ "1.1.1.1" "8.8.8.8" ];

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
      wireless = { enable = true; };
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
      hyprland = { enable = true; };
      xdg = { enable = true; };
    };
  };
}
