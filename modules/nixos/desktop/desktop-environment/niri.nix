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

  outputModule = lib.types.submodule {
    options = {
      off = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable this output entirely.";
      };
      mode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "2560x1440@59.951";
        description = ''
          Resolution and refresh rate. The refresh rate has to match what
          `niri msg outputs` prints, down to the three decimals. Left unset,
          niri picks the preferred mode.
        '';
      };
      scale = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Fractional scale factor.";
      };
      transform = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "90";
        description = "Rotation/flip, e.g. \"90\" for a portrait monitor.";
      };
      position = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              x = lib.mkOption { type = lib.types.int; };
              y = lib.mkOption { type = lib.types.int; };
            };
          }
        );
        default = null;
        description = ''
          Position in the global coordinate space, in logical (scaled) pixels.
          Left unset -- or overlapping an already-placed output -- niri puts
          this output to the right of everything placed so far.
        '';
      };
      layout = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              default-column-width = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    proportion = lib.mkOption { type = lib.types.float; };
                  };
                };
              };
            };
          }
        );
        default = null;
        description = ''
          Per-output layout tweaks. The default column width is a fraction of
          the output's width, so a 0.5 proportion on a 1920-wide monitor gives
          960 logical pixels to each column.
        '';
      };
    };
  };

  renderOutput =
    name: o:
    let
      lines =
        lib.optional o.off "off"
        ++ lib.optional (o.mode != null) ''mode "${o.mode}"''
        ++ [ "scale ${toString o.scale}" ]
        ++ lib.optional (o.transform != null) ''transform "${o.transform}"''
        ++ lib.optional (
          o.position != null
        ) "position x=${toString o.position.x} y=${toString o.position.y}"
        ++
          lib.optional (o.layout != null)
            "layout {
              ${lib.concatStringsSep "\n        " (
                            lib.optional (
                              o.layout.default-column-width != null
                            ) "default-column-width { proportion ${toString o.layout.default-column-width.proportion}; }"
                          )}
          }";
    in
    ''
      output "${name}" {
          ${lib.concatStringsSep "\n    " lines}
      }
    '';

  outputsKdl = lib.concatStringsSep "\n" (
    lib.mapAttrsToList renderOutput config.cfi2017.graphical.niri.outputs
  );
in
{
  options.cfi2017.graphical.niri = {
    enable = lib.mkEnableOption "niri scrollable-tiling wayland compositor";

    outputs = lib.mkOption {
      type = lib.types.attrsOf outputModule;
      default = { };
      description = ''
        Monitors, keyed by niri output name: either a connector name
        ("eDP-1") or "manufacturer model serial" as printed by
        `niri msg outputs`. Prefer the latter for external monitors --
        connector numbering moves between ports and docks, the serial does not.
      '';
    };
  };

  config = lib.mkIf config.cfi2017.graphical.niri.enable {
    # Installs the niri package, its wayland-session (so greetd/tuigreet can
    # list it), portals and the gnome-keyring integration.
    programs.niri.enable = true;

    # Every desk in one catalogue -- no profile switching needed. niri redoes
    # output placement from scratch on every hotplug, so monitors that are not
    # currently connected simply do not take part. Desks never coexist, so they
    # can reuse the same coordinate band; if two ever did, niri logs a warning
    # and puts the loser to the right rather than corrupting the layout. A
    # monitor that is not in here has no configured position and lands to the
    # right of everything else, which is a sane fallback for a strange desk.
    #
    # To enroll a new desk: sit down, run `niri msg outputs`, paste the quoted
    # name, rebuild.
    #
    # Positions describe the *physical* arrangement, because the cursor can only
    # cross where two outputs literally share an edge. Keep everything in one
    # row unless a screen really is stacked: a row shares a full-height edge, so
    # the pointer crosses anywhere along it. Stacking the 1920-wide laptop under
    # 5120 of monitor would leave a narrow band as the only way through, which
    # feels exactly like the monitors are not connected to each other.
    cfi2017.graphical.niri.outputs = {
      # Built-in panel, matched by connector name: that is stable for a
      # soldered-in panel, and its EDID reports no serial at all, so the
      # manufacturer/model/serial form would not be unique anyway. Leftmost,
      # tops aligned with the externals.
      "eDP-1" = {
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
      };

      # --- office: twin landscape S24H85x followed by a portrait Legion
      # The Legion is 3200 logical pixels tall after rotation at 0.8 scale.
      # Centre the 1440-high Samsungs against it: (3200 - 1440) / 2 = 880.
      "Samsung Electric Company S24H85x H4ZKC00255" = {
        position = {
          x = 1920;
          y = 880;
        };
      };
      "Samsung Electric Company S24H85x H4ZMA00945" = {
        position = {
          x = 4480;
          y = 880;
        };
      };
      "Lenovo Group Limited Legion 27Q-10 UPACG819" = {
        scale = 0.8;
        transform = "270";
        position = {
          x = 7040;
          y = 0;
        };
      };

      # --- home: AOC 3440x1440 ultrawide followed by a portrait Legion
      # The Legion is 3200 logical pixels tall after rotation at 0.8 scale.
      # Centre the 1440-high AOC against it: (3200 - 1440) / 2 = 880.
      "PNP(AOC) U34G2G4R3 0x00000B3E" = {
        position = {
          x = 0;
          y = 880;
        };

        layout = {
          default-column-width = {
            proportion = 0.33333;
          };
        };
      };
      "Lenovo Group Limited Legion 27Q-10 UPACC725" = {
        scale = 0.8;
        transform = "270";
        position = {
          x = 3440;
          y = 0;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      slurp
      grim
      grimblast
      swaybg # wallpaper daemon (hyprpaper is Hyprland-only and crashes on niri)
      brightnessctl
      xwayland-satellite # xwayland support for niri
    ];

    home-manager.users.${config.cfi2017.user.name} = { pkgs, ... }: {
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
                // tap
                natural-scroll
                accel-profile "flat"
            }
            mouse {
                accel-profile "flat"
            }
            focus-follows-mouse max-scroll-amount="0%"
        }

        // Generated from cfi2017.graphical.niri.outputs.
        ${outputsKdl}

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

        // Antigravity (Electron/VS Code fork) has no native window transparency,
        // and the usual CSS-injection extensions patch files inside the read-only
        // Nix store. Give it the translucent look at the compositor level instead,
        // matching kitty's 0.90 opacity.
        window-rule {
            match app-id="antigravity"
            opacity 0.90
        }

        // Attachment images get a disposable preview: press q to close it.
        window-rule {
            match app-id="attachment-image-preview"
            open-floating true
        }

        // Zen extension popups are separate browser windows. Match the
        // extension title so this survives changes to Zen's app-id.
        window-rule {
            match title="^[Bb]itwarden.*"
            open-floating true
        }

        screenshot-path "~/pictures/screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

        // waybar is started by its systemd user service (programs.waybar.systemd),
        // which niri activates via graphical-session.target. Do NOT spawn it here
        // as well or you get two overlapping bars.
        //
        // Wallpaper: one swaybg process paints every output, including ones
        // plugged in later. Per-monitor images cannot be pinned declaratively
        // the way output settings can: swaybg matches on connector names
        // (DP-4, DP-6, ...), which move between ports, docks and desks --
        // unlike the manufacturer/model/serial names niri itself matches on.
        // "fill" crops to cover regardless of aspect ratio.
        spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-o" "*" "-i" "${wallpaperTeal}" "-m" "fill"
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
            // Mod+D { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
            Mod+D { spawn "${pkgs.vicinae}/bin/vicinae" "toggle"; }
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
