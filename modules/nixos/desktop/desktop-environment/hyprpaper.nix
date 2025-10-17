{ config, lib, ... }: {
  options.cfi2017.graphical.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper";
  };

  config = lib.mkIf config.cfi2017.graphical.hyprpaper.enable {
    home-manager.users.${config.cfi2017.user.name} = {
      home.file.".config/hypr/hyprpaper.conf".text = ''
        preload = ${/. + _assets/wallpaper.jpg}
        wallpaper = ,${/. + _assets/wallpaper.jpg}
        splash = false
      '';
    };
  };
}
