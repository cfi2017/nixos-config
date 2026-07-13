{
  config,
  lib,
  ...
}:
{
  options.cfi2017.graphical.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper";
  };

  config = lib.mkIf config.cfi2017.graphical.hyprpaper.enable {
    home-manager.users.${config.cfi2017.user.name} = {
      home.file.".config/hypr/hyprpaper.conf".text = ''
        # Managed by NixOS (cfi2017.graphical.hyprpaper)
        ipc = on
        splash = false

        # Preload every image we might reference below.
        preload = ${/. + _assets/wallpaper-space-teal.png}
        preload = ${/. + _assets/wallpaper-space-coral.png}

        # A `wallpaper` line is "<monitor>,<path>". Leaving the monitor field
        # EMPTY ("wallpaper = ,<path>") applies it to every output, so it works
        # no matter how the displays are named. NOTE: the previous config wrote
        # "wallpaper = <path>" with no comma, which hyprpaper reads as a monitor
        # literally named "<path>" with no image -- so nothing was ever drawn.
        wallpaper = ,${/. + _assets/wallpaper-space-teal.png}

        # To give a specific monitor its own wallpaper, name the output (find
        # names with `niri msg outputs` or `hyprctl monitors`) and add a line,
        # e.g. a coral variant on the second display:
        # wallpaper = DP-2,${/. + _assets/wallpaper-space-coral.png}
      '';
    };
  };
}
