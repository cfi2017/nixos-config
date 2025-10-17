{ config, pkgs, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
