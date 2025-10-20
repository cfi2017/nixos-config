{ lib, config, pkgs, ... }: {
  config = {
    programs.neovim = {
      enable = true;
      withPython3 = true;
      withNodeJs = true;
    };
    home-manager.users.${config.cfi2017.user.name} = {config, ...}: {
      xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/cfi/code/personal/nixos-config/modules/shared/utils/nvim-config";
    };
  };
}
