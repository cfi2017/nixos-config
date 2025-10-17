{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.nh = {
        enable = true;
        clean.enable = false;
        flake =
          "${config.cfi2017.user.homeDirectory}/${config.cfi2017.user.codeDir}/personal/nixos-config";
      };
    };
  };
}
