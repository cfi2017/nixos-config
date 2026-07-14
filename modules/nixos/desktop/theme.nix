{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.cfi2017.graphical.theme = {
    enable = lib.mkOption {
      default = true;
      description = "Enable graphical theme configuration including fonts, GTK, and Qt theming";
    };
  };

  config = lib.mkIf config.cfi2017.graphical.theme.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir = {
        enable = true;
      };
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ config.cfi2017.font ];
          sansSerif = [ config.cfi2017.font ];
          serif = [ config.cfi2017.font ];
        };
      };
      packages = with pkgs; [
        nerd-fonts._0xproto
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
      ];
    };

    programs.dconf.enable = true;

    # System-level catppuccin is intentionally off (theming is done per-user via
    # home-manager). Pin autoEnable to the current enable value so the upcoming
    # semantics change is a no-op here and stops warning.
    catppuccin.autoEnable = false;

    home-manager.users.${config.cfi2017.user.name} =
      { pkgs, ... }:
      {
        catppuccin = {
          cursors = {
            enable = true;
            accent = "dark";
            flavor = config.cfi2017.colorScheme.flavor;
          };
          hyprland.enable = false;
        };

        # Advertise a dark preference through the XDG "appearance" portal
        # (org.freedesktop.appearance color-scheme). xdg-desktop-portal-gtk reads
        # this gsettings key and reports it to portal-aware apps (Firefox/Zen,
        # Chrome) as prefers-color-scheme. Without it the portal answers "no
        # preference" (0), which browsers render as *light*. This only started
        # mattering once the gtk/gnome portals were added for niri screencast
        # support -- before that no Settings portal existed and apps fell back to
        # inferring dark from the GTK theme (gtk-application-prefer-dark-theme).
        dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

        gtk = {
          enable = true;
          gtk2.extraConfig = "gtk-application-prefer-dark-theme = true;";
          gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

          font = {
            name = config.cfi2017.font;
            size = 10;
          };

          # catppuccin = {
          #   flavor = config.cfi2017.colorScheme.flavor;
          #   accent = config.cfi2017.colorScheme.accent;
          #   size = "compact";
          # };
        };

        qt = {
          enable = true;
          platformTheme.name = "kvantum";
          style.name = "kvantum";
        };
      };
  };
}
