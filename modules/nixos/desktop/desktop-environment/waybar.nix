{
  config,
  lib,
  ...
}:
{
  options.cfi2017.graphical.waybar = {
    enable = lib.mkEnableOption "Waybar Status Bar";
  };

  config = lib.mkIf config.cfi2017.graphical.waybar.enable {
    home-manager.users.${config.cfi2017.user.name} =
      { pkgs, ... }:
      {
        programs.waybar = {
          enable = true;
          systemd.enable = true;
          settings = [
            {
              layer = "top";
              position = "top";
              # Slim, dense bar: hug the top edge (no margin) and let the module
              # padding provide the only separation (no inter-module spacing).
              spacing = 0;
              # output = [
              #   "eDP-1"
              #   "DP-2"
              #   "DP-4"
              #   "DP-5"
              #   "HDMI-A-1"
              # ];
              # Both modules are listed so the same bar works under either
              # compositor; each only renders when its compositor is running.
              modules-left = [
                "niri/workspaces"
                "hyprland/workspaces"
              ];
              modules-center = [ ];
              modules-right = [
                "cpu"
                "memory"
                "backlight"
                "network"
                "battery"
                "custom/notifications"
                "clock"
                "tray"
                "custom/lock"
                "custom/power"
              ];

              "niri/workspaces" = {
                disable-scroll = true;
                all-outputs = false;
                # niri workspaces are unnamed, so the default {value} renders
                # blank; {index} shows the workspace numbers.
                format = "{index}";
              };

              "hyprland/workspaces" = {
                disable-scroll = true;
                sort-by-name = false;
                all-outputs = false;
                #persistent-workspaces = {
                #  "Home" = [ ];
                #  "2" = [ ];
                #  "3" = [ ];
                #  "4" = [ ];
                #  "5" = [ ];
                #  "6" = [ ];
                #  "7" = [ ];
                #  "8" = [ ];
                #  "9" = [ ];
                #  "10" = [ ];
                #};
              };

              "tray" = {
                icon-size = 16;
                spacing = 6;
              };

              # Compact, informational readouts (the point of an old-school bar).
              "cpu" = {
                interval = 2;
                format = "󰻠 {usage}%";
                tooltip = false;
              };

              "memory" = {
                interval = 5;
                format = "󰍛 {used:0.1f}G";
                tooltip = false;
              };

              "clock" = {
                timezone = "Europe/Zurich";
                tooltip-format = ''
                  <big>{:%Y %B}</big>
                  <tt><small>{calendar}</small></tt>'';
                format = "{:%a %d %b  %H:%M}";
                format-alt = "{:%Y-%m-%d %H:%M:%S}";
              };

              "network" = {
                format-wifi = "󰤨 {signalStrength}%";
                format-ethernet = "󰈀 {ipaddr}";
                format-linked = "󰌘 {ifname}";
                format-disconnected = "󰤭";
                tooltip-format = "{ifname}: {ipaddr}/{cidr}";
                format-alt = "{ifname}: {ipaddr}/{cidr}";
              };

              "backlight" = {
                device = "intel_backlight";
                format = "{icon} {percent}%";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
              };

              "battery" = {
                states = {
                  warning = 30;
                  critical = 15;
                };
                format = "{icon} {capacity}%";
                format-charging = "󰂄 {capacity}%";
                format-plugged = "󱟢 {capacity}%";
                format-alt = "{icon}";
                format-icons = [
                  "󰁺"
                  "󰁻"
                  "󰁼"
                  "󰁽"
                  "󰁾"
                  "󰁿"
                  "󰂀"
                  "󰂁"
                  "󰂂"
                  "󰁹"
                ];
              };

              ## https://github.com/Frost-Phoenix/nixos-config/blob/4d75ca005a820672a43db9db66949bd33f8fbe9c/modules/home/waybar/settings.nix#L116
              "custom/notifications" = {
                tooltip = false;
                format = "{icon}";
                format-icons = {
                  notification = "󱥁 <span foreground='red'><sup></sup></span>";
                  none = "󰍥 ";
                  dnd-notification = "󱙍 <span foreground='red'><sup></sup></span>";
                  dnd-none = "󱙎 ";
                  inhibited-notification = "󱥁 <span foreground='red'><sup></sup></span>";
                  inhibited-none = "󰍥 ";
                  dnd-inhibited-notification = "󱙍 <span foreground='red'><sup></sup></span>";
                  dnd-inhibited-none = "󱙎 ";
                };
                return-type = "json";
                exec-if = "which swaync-client";
                exec = "swaync-client -swb";
                on-click = "swaync-client -t -sw";
                on-click-right = "swaync-client -d -sw";
                escape = true;
              };
              ##

              "custom/lock" = {
                tooltip = false;
                on-click = "${pkgs.hyprlock}/bin/hyprlock";
                format = " ";
              };

              "custom/power" = {
                tooltip = false;
                on-click = "${pkgs.wlogout}/bin/wlogout &";
                format = " ";
              };
            }
          ];

          style = ''
            * {
              font-family: '0xProto Nerd Font';
              font-size: 12px;
              min-height: 0;
            }

            /* One continuous slim bar hugging the top edge: no pills, no
               rounding, no floating margins. */
            #waybar {
              background: @mantle;
              color: @text;
              border-bottom: 1px solid @surface0;
            }

            /* Every module is flat, square and tightly padded. */
            #workspaces,
            #workspaces button,
            #cpu,
            #memory,
            #backlight,
            #network,
            #battery,
            #clock,
            #tray,
            #custom-notifications,
            #custom-lock,
            #custom-power {
              border-radius: 0;
              margin: 0;
              padding: 0 6px;
              background: transparent;
            }

            /* Workspaces: square blocks, filled highlight on the active one. */
            #workspaces button {
              color: @overlay1;
            }
            #workspaces button.active {
              color: @base;
              background-color: @peach;
            }
            #workspaces button:hover {
              color: @peach;
              background: @surface0;
            }

            /* Keep the useful colour coding, drop the boxes. */
            #cpu { color: @green; }
            #memory { color: @teal; }
            #backlight { color: @yellow; }
            #network { color: @sky; }
            #battery { color: @green; }
            #battery.charging { color: @green; }
            #battery.warning:not(.charging) { color: @peach; }
            #battery.critical:not(.charging) { color: @red; }
            #clock { color: @blue; }
            #custom-notifications { color: @peach; }
            #custom-lock { color: @lavender; }
            #custom-power { color: @red; padding-right: 10px; }


            @define-color rosewater #f4dbd6;
            @define-color flamingo #f0c6c6;
            @define-color pink #f5bde6;
            @define-color mauve #c6a0f6;
            @define-color red #ed8796;
            @define-color maroon #ee99a0;
            @define-color peach #f5a97f;
            @define-color yellow #eed49f;
            @define-color green #a6da95;
            @define-color teal #8bd5ca;
            @define-color sky #91d7e3;
            @define-color sapphire #7dc4e4;
            @define-color blue #8aadf4;
            @define-color lavender #b7bdf8;
            @define-color text #cad3f5;
            @define-color subtext1 #b8c0e0;
            @define-color subtext0 #a5adcb;
            @define-color overlay2 #939ab7;
            @define-color overlay1 #8087a2;
            @define-color overlay0 #6e738d;
            @define-color surface2 #5b6078;
            @define-color surface1 #494d64;
            @define-color surface0 #363a4f;
            @define-color base #24273a;
            @define-color mantle #1e2030;
            @define-color crust #181926;
          '';
        };
      };
  };
}
