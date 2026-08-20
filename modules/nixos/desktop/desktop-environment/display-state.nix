# Probes the physical display/power state from sysfs, for the places that need
# to answer "is this laptop actually usable right now?" -- the lid guard in
# ../laptop.nix and the hypridle suspend gate. Deliberately kept out of the
# compositor so it behaves the same under niri and hyprland, and so it still
# works from a udev-triggered system service where no session exists at all.
{ pkgs }:
pkgs.writeShellApplication {
  name = "display-state";
  text = ''
    lid_closed() {
      grep -qs closed /proc/acpi/button/lid/*/state
    }

    # Any connected connector that is not the built-in panel. Mirrors what
    # logind counts for HandleLidSwitchDocked.
    external_connected() {
      local status
      for status in /sys/class/drm/card*-*/status; do
        case "$status" in
          *eDP*|*LVDS*|*DSI*) continue ;;
        esac
        if [ "$(cat "$status")" = connected ]; then
          return 0
        fi
      done
      return 1
    }

    # type=Mains only: USB-C PD sources (ucsi-source-psy-*) also sit in
    # /sys/class/power_supply with online=1 and would give a false positive.
    on_ac() {
      local supply
      for supply in /sys/class/power_supply/*; do
        if [ -r "$supply/type" ] && [ "$(cat "$supply/type")" = Mains ] \
          && [ -r "$supply/online" ] && [ "$(cat "$supply/online")" = 1 ]; then
          return 0
        fi
      done
      return 1
    }

    case "''${1:-}" in
      lid-closed)         lid_closed ;;
      external-connected) external_connected ;;
      on-ac)              on_ac ;;
      *) echo "usage: display-state lid-closed|external-connected|on-ac" >&2; exit 2 ;;
    esac
  '';
}
