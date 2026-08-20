{
  config,
  lib,
  pkgs,
  ...
}:
let
  displayState = import ./desktop-environment/display-state.nix { inherit pkgs; };

  # Undocking with the lid shut leaves the machine awake with zero active
  # outputs: logind evaluates lid policy only on the lid *event*, never on a
  # display hotplug, and niri keeps the internal panel off for as long as the
  # lid is closed. Without this the laptop stays awake in your bag.
  lidGuard = pkgs.writeShellApplication {
    name = "lid-guard";
    runtimeInputs = [
      displayState
      pkgs.systemd
    ];
    text = ''
      # A dock going away emits a burst of drm change events, and connectors
      # are reported gone slightly before udev settles. Re-read after.
      sleep 3

      if display-state lid-closed && ! display-state external-connected; then
        systemctl suspend
      fi
    '';
  };
in
{
  config = lib.mkIf (config.cfi2017.graphical.enable && config.cfi2017.graphical.laptop) {
    # Docked -- or with any external display connected -- closing the lid does
    # nothing, and niri turns the internal panel off by itself. Everything else
    # suspends, including "charger attached but no monitor", which is a bag
    # rather than a desk.
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    systemd.services.lid-guard = {
      description = "Suspend when the last external display goes away with the lid shut";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe lidGuard;
      };
    };

    services.udev.extraRules = ''
      ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${pkgs.systemd}/bin/systemctl start --no-block lid-guard.service"
    '';
  };
}
