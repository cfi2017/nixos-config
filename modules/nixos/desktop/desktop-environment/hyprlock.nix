{ pkgs, config, lib, ... }: {
  options.cfi2017.graphical.hyprlock = {
    enable = lib.mkEnableOption "hyprlock";
  };

  config = lib.mkIf config.cfi2017.graphical.hyprlock.enable {
    home-manager.users.${config.cfi2017.user.name} = {
      home.packages = [ pkgs.hyprlock ];

      xdg.configFile."hypr/hyprlock.conf".text = ''
        general = {
          no_fade_in = false
          grace = 0
          disable_loading_bar = true
        }

        background {
          path = ${./_assets/lockscreen.png}
          blur_passes = 1;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }

        input-field {
          size = 250, 60
          outline_thickness = 2
          dots_size = 0.2
          dots_spacing = 0.2
          dots_center = true
          outer_color = rgba(0, 0, 0, 0)
          inner_color = rgba(0, 0, 0, 0.5)
          font_color = rgb(200, 200, 200)
          fade_on_empty = false
          placeholder_text = <i>UwU who's a good puppy?</i>
          hide_input = false
          position = 0,0
          halign = center
          valign = center
          }

        lablel {
          font_family = ${config.cfi2017.font}
          text = Yo..., Wassup!
          font_size = 25
          position = 0,300
          halign = center
          valign = center
        }
      '';
    };
    security.pam.services.hyprlock = { };
  };
}
