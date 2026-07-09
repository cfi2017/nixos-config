### Machines

At the top level, the `machines/` directory defines the individual hosts. Each machine has a dedicated file (e.g., `machines/e14/default.nix`) that specifies its hardware configuration, network settings, and which modules to import. This is where you would define things like disk layouts, graphics drivers, and other host-specific parameters.

### Modules

The core logic is organized in the `modules/` directory, which is split into three categories:

- **Shared Modules** (`modules/shared`): This is the foundation for all systems, regardless of the operating system. It includes common configurations for `home-manager`, development tools (`development/`), base system settings (`config/`), and essential utilities like ZSH, Git, and SSH (`utils/`). These modules ensure a consistent user experience across every machine.

- **NixOS Modules** (`modules/nixos`): These modules are specific to Linux hosts. They handle system-level concerns like network connectivity (`connectivity/`), the desktop environment (Hyprland, applications, theming in `desktop/`), storage with ZFS (`storage/`), and virtualization with Docker and KVM (`virtualization/`).

### Additional Components

- **lib/**: A collection of custom helper functions and utilities that are used throughout the flake.
- **overlays/**: Overlays are used to modify or extend the `nixpkgs` package set with custom packages or versions.
- **pkgs/**: Custom packages and derivations that are not available in other sources.
- **secrets/**: Contains secret files encrypted with SOPS, which are securely decrypted at build time.

### niri Cheat Sheet

`Mod` is the **Super** key. Bindings are defined in
`modules/nixos/desktop/desktop-environment/niri.nix`. Press
`Mod+F1` at any time to show the live hotkey overlay.

**Apps & session**

| Keys | Action |
| --- | --- |
| `Mod+Return` | Open terminal (kitty) |
| `Mod+D` | App launcher (fuzzel) |
| `Mod+Alt+E` | File manager (yazi in kitty) |
| `Mod+Alt+V` | Clipboard history (cliphist → fuzzel) |
| `Mod+Alt+N` | Toggle notification centre (swaync) |
| `Mod+Alt+L` | Lock screen (hyprlock) |
| `Mod+Shift+Q` | Close focused window |
| `Mod+Shift+E` | Quit niri (exit session) |
| `Mod+Shift+P` | Power off monitors |
| `Mod+F1` | Show hotkey overlay |

The screen also auto-locks on idle (hypridle → hyprlock), the same as the
hyprland session. Laptop volume/mic/brightness keys (`XF86Audio*`,
`XF86MonBrightness*`) work too, including while locked.

**Focus (niri is a scrollable-tiling WM — windows live in horizontal columns)**

| Keys | Action |
| --- | --- |
| `Mod+H` / `Mod+L` | Focus column left / right |
| `Mod+J` / `Mod+K` | Focus window down / up (within a column) |
| `Mod+1` … `Mod+9` | Focus workspace 1–9 |

**Move windows & columns**

| Keys | Action |
| --- | --- |
| `Mod+Shift+H` / `Mod+Shift+L` | Move column left / right |
| `Mod+Shift+J` / `Mod+Shift+K` | Move window down / up |
| `Mod+Shift+1` … `Mod+Shift+9` | Move column to workspace 1–9 |

**Layout & sizing**

| Keys | Action |
| --- | --- |
| `Mod+R` | Cycle preset column widths (⅓ → ½ → ⅔) |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+V` | Toggle floating |
| `Mod+Ctrl+H` / `Mod+Ctrl+L` | Shrink / grow column width by 10% |
| `Mod+Ctrl+K` / `Mod+Ctrl+J` | Shrink / grow window height by 10% |

**Screenshots** (saved to `~/pictures/screenshots/`)

| Keys | Action |
| --- | --- |
| `Print` | Interactive region screenshot |
| `Ctrl+Print` | Whole screen |
| `Alt+Print` | Focused window |
