{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.eza = {
        enable = true;
        enableZshIntegration = true;
        icons = "auto";
        git = true;
      };
    };
  };
}
