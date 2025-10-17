{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        settings = { log = { enabled = false; }; };
      };
    };
  };
}
