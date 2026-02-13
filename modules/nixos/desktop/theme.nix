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

    home-manager.users.${config.cfi2017.user.name} =
      { pkgs, ... }:
      {
        catppuccin = {
          cursors = {
            enable = true;
            accent = "dark";
            flavor = config.cfi2017.colorScheme.flavor;
          };
        };

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
