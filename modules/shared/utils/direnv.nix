{ config, lib, ... }: {
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeCacheLinks = [ ".local/share/direnv" ];
          systemCacheLinks = [ "/root/.local/share/direnv" ];
        })
      ];
    })
    {
      home-manager.users.${config.cfi2017.user.name} = {
        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };
      };
    }
  ];
}
