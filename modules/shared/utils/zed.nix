{ config, pkgs, ... }:
{
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "nix"
          "toml"
          "rust"
        ];
        userSettings = {
          theme = {
            mode = "system";
          };
          hour_format = "hour24";
          vim_mode = true;
        };
      };
    };
  };
}
