{
  config,
  lib,
  pkgs,
  ...
}:
let
  displayState = import ./display-state.nix { inherit pkgs; };

  # hypridle is shared by the hyprland and niri sessions, so dispatch on
  # whichever compositor actually owns the session -- `hyprctl dispatch dpms`
  # is a no-op under niri. NIRI_SOCKET is present in the systemd user
  # environment, so it reaches this service.
  dpms = pkgs.writeShellScript "dpms" ''
    if [ -n "''${NIRI_SOCKET:-}" ]; then
      ${config.programs.niri.package}/bin/niri msg action "power-$1-monitors"
    elif [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms "$1"
    fi
  '';

  # Parked at a desk on mains power (typically lid shut, running off the
  # externals): lock and blank, but stay up. On battery, or with no external
  # display, suspend as before.
  maybeSuspend = pkgs.writeShellScript "maybe-suspend" ''
    if ${lib.getExe displayState} external-connected \
      && ${lib.getExe displayState} on-ac; then
      exit 0
    fi
    ${pkgs.systemd}/bin/systemctl suspend
  '';
in
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
            after_sleep_cmd = "${dpms} on";
            # Runs while hypridle holds a logind sleep inhibitor, so the lock is
            # up before the machine goes down. Covers every suspend path at
            # once: lid close, the idle timer below, wlogout, and a manual
            # `systemctl suspend`.
            before_sleep_cmd = "loginctl lock-session";
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
              on-timeout = "${dpms} off";
              on-resume = "${dpms} on";
            }
            {
              timeout = 900;
              on-timeout = "${maybeSuspend}";
            }
          ];
        };
      };
    };
  };
}
