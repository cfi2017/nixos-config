### Machines

At the top level, the `machines/` directory defines the individual hosts. Each machine has a dedicated file (e.g., `machines/e14/default.nix`) that specifies its hardware configuration, network settings, and which modules to import. This is where you would define things like disk layouts, graphics drivers, and other host-specific parameters.

For a fresh NixOS laptop, follow the [new-laptop onboarding guide](docs/onboarding-new-laptop.md). It covers the current ZFS/impermanence layout and bootstrapping SOPS with the authorized YubiKey before the first install.

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

# Rustic backups

The optional `cfi2017.backup.rustic` service backs up every enabled
impermanence storage root.

Add a multiline SOPS secret named `backup/rustic/environment` to
`secrets/secrets.yaml`. For an S3-compatible OpenDAL repository it should have
the following EnvironmentFile format (the repository password deliberately
does not belong in this secret):

```text
RUSTIC_REPOSITORY=opendal:s3:my-bucket
RUSTIC_REPO_OPT_REGION=eu-central-1
RUSTIC_REPO_OPT_ENDPOINT=https://s3.example.com
RUSTIC_REPO_OPT_ACCESS_KEY_ID=example-access-key
RUSTIC_REPO_OPT_SECRET_ACCESS_KEY=example-secret-key
```

The endpoint is optional for AWS S3. The repository password is intentionally
not stored in SOPS. Generate a random password and encrypt it directly to the
age recipient for this one host plus every YubiKey that should be able to
recover it:

```bash
age-plugin-yubikey --list
rage-keygen -y ~/.config/sops/age/keys.txt
openssl rand -base64 48 | rage --armor \
  --recipient age1HOST... \
  --recipient age1yubikey1FIRST... \
  --recipient age1yubikey1SECOND... \
  --output secrets/t14-rustic-password.age
```

The resulting file contains only public-key-encrypted ciphertext and can be
committed with the configuration. Keeping it outside the Rustic repository is
important: otherwise recovery would require the password in order to retrieve
the encrypted password. Do not add the password or this envelope to SOPS; its
broader recipient list is intentionally not part of the backup trust boundary.

Then enable the service on the matching host:

```nix
cfi2017.backup.rustic = {
  enable = true;
  encryptedPasswordFile = ../../secrets/t14-rustic-password.age;
  # Defaults to config.sops.age.keyFile. Override this if the host uses a
  # dedicated backup identity.
  hostIdentityFile = "/path/to/this-hosts/age-identity";
};
```

The timer runs daily by default, initializes an empty repository on its first
run, and applies the configured retention policy after each successful backup.
Rustic invokes `rage` at runtime through its password-command interface. The
host identity permits unattended backups; any configured YubiKey recipient can
decrypt the same envelope for recovery. The plaintext password is never
written to disk or placed directly in the service environment.
Test it with `sudo systemctl start rustic-backup.service` and inspect it with
`journalctl -u rustic-backup.service`.
