{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        # Pin the shell wrapper name; upstream changed the default "yy" -> "y".
        shellWrapperName = "yy";
        settings = {
          log = {
            enabled = false;
          };
        };
      };
    };
  };
}
