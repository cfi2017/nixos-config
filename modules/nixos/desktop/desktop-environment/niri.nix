{
  config,
  lib,
  pkgs,
  ...
}:
let
  kitty-cwd = import ./kitty-cwd.nix { inherit pkgs; };
  # Wallpapers live next to this module. hyprpaper crashes under niri (it is a
  # Hyprland-only tool), so the niri session paints the background with swaybg.
  wallpaperTeal = ./_assets/wallpaper-space-teal.png;
  wallpaperCoral = ./_assets/wallpaper-space-coral.png;
in
{
  options.cfi2017.graphical.niri = {
    enable = lib.mkEnableOption "niri scrollable-tiling wayland compositor";
  };

  config = lib.mkIf config.cfi2017.graphical.niri.enable {
    # Installs the niri package, its wayland-session (so greetd/tuigreet can
    # list it), portals and the gnome-keyring integration.
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      slurp
      grim
      grimblast
      swaybg # wallpaper daemon (hyprpaper is Hyprland-only and crashes on niri)
      brightnessctl
      xwayland-satellite # xwayland support for niri
    ];

    home-manager.users.${config.cfi2017.user.name} =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          qt5.qtwayland
          (lib.hiPrio qt6.qtwayland)
        ];

        services.cliphist.enable = true;

        xdg.configFile."niri/config.kdl".text = ''
          // Managed by NixOS (cfi2017.graphical.niri)

          input {
              keyboard {
                  xkb {
                      layout "ch"
                  }
              }
              touchpad {
                  tap
                  natural-scroll
                  accel-profile "flat"
              }
              mouse {
                  accel-profile "flat"
              }
              focus-follows-mouse
          }

          output "eDP-1" {
              scale 1.0
          }

          layout {
              gaps 8
              center-focused-column "never"

              preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
              }

              default-column-width { proportion 0.5; }

              focus-ring {
                  width 2
              }

              border {
                  off
              }
          }

          prefer-no-csd

          screenshot-path "~/pictures/screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

          // waybar is started by its systemd user service (programs.waybar.systemd),
          // which niri activates via graphical-session.target. Do NOT spawn it here
          // as well or you get two overlapping bars.
          //
          // Wallpaper: one swaybg process paints every output. Outputs are named
          // as reported by `niri msg outputs`; the two Samsung externals get the
          // matched teal/coral pair, the laptop panel gets teal. "fill" crops to
          // cover regardless of aspect ratio.
          spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-o" "eDP-1" "-i" "${wallpaperTeal}" "-m" "fill" "-o" "DP-6" "-i" "${wallpaperTeal}" "-m" "fill" "-o" "DP-7" "-i" "${wallpaperCoral}" "-m" "fill"
          spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet"
          spawn-at-startup "${pkgs.blueman}/bin/blueman-applet"
          spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
          // Start gnome-keyring (secrets/ssh/gpg) like the hyprland session does.
          spawn-at-startup "sh" "-c" "eval $(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets,ssh,gpg,pkcs11)"

          environment {
              DISPLAY ":0"
              NIXOS_OZONE_WL "1"
              QT_QPA_PLATFORM "wayland"
              QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
              SDL_VIDEODRIVER "wayland"
              GDK_BACKEND "wayland"
              _JAVA_AWT_WM_NONREPARENTING "1"
              LIBVA_DRIVER_NAME "nvidia"
              GBM_BACKEND "nvidia-drm"
              __GLX_VENDOR_LIBRARY_NAME "nvidia"
          }

          binds {
              // F1 instead of the upstream Mod+Shift+Slash: on the Swiss (ch)
              // layout "/" is Shift+7, so the slash keysym already needs Shift
              // and Mod+Shift+Slash never resolves.
              Mod+F1 { show-hotkey-overlay; }

              Mod+Return { spawn "${pkgs.kitty}/bin/kitty"; }
              // Same as Mod+Return, but inherits the focused terminal's cwd.
              Mod+Shift+Return { spawn "${kitty-cwd}"; }
              Mod+D { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
              Mod+Shift+Q { close-window; }

              Mod+H { focus-column-left; }
              Mod+L { focus-column-right; }
              Mod+J { focus-window-down; }
              Mod+K { focus-window-up; }

              Mod+Shift+H { move-column-left; }
              Mod+Shift+L { move-column-right; }
              Mod+Shift+J { move-window-down; }
              Mod+Shift+K { move-window-up; }

              // Vertical splits. niri columns can stack several windows on top
              // of each other -- that stack IS the vertical split. A new window
              // opens in its own column, so to put it *below* the focused one
              // you pull it into the current column ("consume"); Period pushes
              // the bottom window back out into its own column ("expel").
              // Once stacked, Mod+J / Mod+K move focus up/down within the split.
              Mod+Comma  { consume-window-into-column; }
              Mod+Period { expel-window-from-column; }

              // Switch focus between physical monitors.
              Mod+Ctrl+Left  { focus-monitor-left; }
              Mod+Ctrl+Down  { focus-monitor-down; }
              Mod+Ctrl+Up    { focus-monitor-up; }
              Mod+Ctrl+Right { focus-monitor-right; }

              // Send the focused column to the monitor in that direction.
              Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
              Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
              Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
              Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }

              // Workspaces are stacked vertically per monitor; move up/down the
              // stack. U/I mirror the Page keys for home-row reach.
              Mod+Page_Down { focus-workspace-down; }
              Mod+Page_Up   { focus-workspace-up; }
              Mod+U         { focus-workspace-down; }
              Mod+I         { focus-workspace-up; }

              // Carry the focused column to the workspace above/below.
              Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
              Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
              Mod+Ctrl+U         { move-column-to-workspace-down; }
              Mod+Ctrl+I         { move-column-to-workspace-up; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }

              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+Shift+9 { move-column-to-workspace 9; }

              Mod+V { toggle-window-floating; }
              Mod+F { maximize-column; }
              Mod+Shift+F { fullscreen-window; }
              Mod+R { switch-preset-column-width; }

              Mod+Ctrl+H { set-column-width "-10%"; }
              Mod+Ctrl+L { set-column-width "+10%"; }
              Mod+Ctrl+K { set-window-height "-10%"; }
              Mod+Ctrl+J { set-window-height "+10%"; }

              // Lock screen (same hyprlock the hypridle idle-timer uses).
              Mod+Alt+L { spawn "${pkgs.hyprlock}/bin/hyprlock"; }
              // File manager, notification centre, clipboard history (parity with hyprland).
              Mod+Alt+E { spawn "${pkgs.kitty}/bin/kitty" "--hold" "-e" "${pkgs.yazi}/bin/yazi"; }
              Mod+Alt+N { spawn "${pkgs.swaynotificationcenter}/bin/swaync-client" "-t" "-sw"; }
              Mod+Alt+V { spawn "sh" "-c" "${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"; }

              Print { screenshot; }
              Ctrl+Print { screenshot-screen; }
              Alt+Print { screenshot-window; }

              // Volume / mic / brightness — usable even while the screen is locked.
              XF86AudioRaiseVolume allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"; }
              XF86AudioLowerVolume allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
              XF86AudioMute        allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
              XF86AudioMicMute     allow-when-locked=true { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
              XF86MonBrightnessUp   allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+"; }
              XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"; }

              Mod+Shift+E { quit; }
              Mod+Shift+P { power-off-monitors; }
          }
        '';
      };
  };
}
