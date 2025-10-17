{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.k9s = { enable = true; };
    };
  };
}
