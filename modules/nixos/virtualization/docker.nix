{ pkgs, lib, config, ... }: {
  options = {
    cfi2017 = {
      development.virtualisation = {
        docker.enable = lib.mkEnableOption "docker";
      };
    };
  };

  config = lib.mkIf config.cfi2017.development.virtualisation.docker.enable {
    cfi2017.core.zfs.systemCacheLinks = [ "/opt/docker" ];

    virtualisation.docker = {
      enable = true;
      extraOptions =
        "--data-root ${config.cfi2017.persistence.dataPrefix}/var/lib/docker";
      storageDriver = "zfs";
    };

    home-manager.users.cfi = { home.packages = with pkgs; [ docker-compose ]; };
    users.users.cfi.extraGroups = [ "docker" ];
  };
}
