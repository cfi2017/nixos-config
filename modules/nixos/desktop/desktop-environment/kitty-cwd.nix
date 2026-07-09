# Opens a new kitty window in the working directory of the currently-focused
# terminal. Works under both niri and hyprland: it asks the running compositor
# for the focused window's PID, walks down the process tree to the foreground
# child, and reads its /proc/<pid>/cwd. If the focused window is not a terminal
# (or the cwd can't be resolved) it falls back to a plain kitty in $HOME.
#
# `niri`/`hyprctl` are invoked from PATH on purpose: in a live session those are
# the compositor's own binaries, so their IPC version always matches.
{ pkgs }:
pkgs.writeShellScript "kitty-cwd" ''
  set -eu

  pid=""
  if [ -n "''${NIRI_SOCKET:-}" ]; then
    pid=$(niri msg --json focused-window | ${pkgs.jq}/bin/jq -r '.pid // empty')
  elif [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    pid=$(hyprctl -j activewindow | ${pkgs.jq}/bin/jq -r '.pid // empty')
  fi

  dir=""
  if [ -n "$pid" ]; then
    # Descend to the deepest child so we track the foreground process's cwd
    # (e.g. after `cd` in the shell) rather than the terminal emulator itself.
    while child=$(${pkgs.procps}/bin/pgrep -P "$pid" | head -n1) && [ -n "$child" ]; do
      pid=$child
    done
    dir=$(readlink "/proc/$pid/cwd" 2>/dev/null || true)
  fi

  if [ -n "$dir" ] && [ -d "$dir" ]; then
    exec ${pkgs.kitty}/bin/kitty --directory "$dir"
  else
    exec ${pkgs.kitty}/bin/kitty
  fi
''
