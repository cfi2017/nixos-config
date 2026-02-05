{ config, ... }:
{
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.kitty = {
        enable = true;
        font = {
          name = config.cfi2017.font;
          size = if config.cfi2017.isDarwin then 11 else 10;
        };
        settings = {
          enable_audio_bell = false;
          enable_visual_bell = false;
          remember_window_size = false;
          confirm_os_window_close = 0;
          disable_ligatures = "always";

          # Font config
          font_family = config.cfi2017.font;
          adjust_line_height = 3;

          background_opacity = "0.95";
          background_blur = 60;

          # Window config
          window_margin_width = 5;
          single_window_margin_width = -1;

          cursor_trail = 3;
        };
        keybindings = {
          "ctrl+c" = "copy_and_clear_or_interrupt";
          "ctrl+v" = "paste_from_clipboard";
          "ctrl+shift+plus" = "change_font_size all +2.0";
          "ctrl+shift+minus" = "change_font_size all -2.0";
        };
      };
    };
  };
}
