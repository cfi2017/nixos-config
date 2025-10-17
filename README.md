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
