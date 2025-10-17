{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
