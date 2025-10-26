{ config, lib, ... }:
{
  options.cfi2017.graphical.hypridle = {
    enable = lib.mkEnableOption "hypridle";
  };

  config = lib.mkIf config.cfi2017.graphical.hypridle.enable {
    home-manager.users.${config.cfi2017.user.name} = {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 200;
              on-timeout = "brightnessctl -s set 10";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = 300;
              on-timeout = "hyprlock";
            }
            {
              timeout = 400;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 900;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    };
  };
}
