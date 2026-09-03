# Enrolling `t14` with nixos-anywhere

This is an attended remote installation. The controller holds the repository
and the YubiKey; the T14 boots a NixOS installer and is managed over SSH.
Disko automates the destructive storage work, but the operator must identify
the target disk and explicitly start the installation.

> **This erases the selected disk.** Never replace the disk safety sentinel
> until the stable disk identity has been checked on the T14 itself.

## 1. Review the prepared host

The `t14` configuration is already registered in `flake.nix`. Unlike `e14`, it
opts into Disko through `machines/t14/disko.nix`. Review these assumptions:

- The laptop is x86-64 and boots with UEFI.
- `system.stateVersion` and `cfi2017.stateVersion` are `26.05`.
- Swap is 64 GiB. It must be large enough for the intended hibernation load.
- The hardware-neutral bootstrap configuration in
  `machines/t14/hardware.nix` will be replaced during enrollment.
- No CPU-vendor, GPU-vendor, fingerprint-reader, or model-specific settings
  have been guessed. Add these after inspecting the generated hardware report.

The Disko layout creates an EFI system partition, passphrase-protected swap,
and a LUKS-encrypted Btrfs filesystem with an impermanence topology:

| Mount | Dataset/device |
| --- | --- |
| `/boot` | FAT32 partition labelled `EFI` |
| `/` | Btrfs subvolume `root` |
| `/nix` | Btrfs subvolume `nix` |
| `/nix/store` | Btrfs subvolume `nix-store` |
| `/cache` | Btrfs subvolume `cache` |
| `/data` | Btrfs subvolume `data` |
| swap | LUKS mapping `cryptswap`, labelled `swap` |

Disko also creates pristine `blank` and archival `old-roots` subvolumes. On
each boot, the initrd moves the previous `root` below `old-roots`, creates a
fresh writable snapshot of `blank`, and removes archived roots older than 14
days. The persistent subvolumes are outside the root snapshot.

## 2. Boot the target and expose SSH

Boot a recent NixOS minimal installer on the T14 and connect it to the network.
Set a temporary password and start SSH:

```console
sudo -i
passwd nixos
systemctl start sshd
ip -brief address
```

From the controller, verify access without disabling host-key checking:

```console
ssh nixos@<target-ip>
```

Record the installer host-key fingerprint shown by SSH and confirm it from the
T14 console with:

```console
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

## 3. Authenticate the controller

Plug the YubiKey into the controller. Load its resident SSH credential and
confirm both private-flake and SOPS access:

```console
eval "$(ssh-agent -s)"
ssh-add -K
ssh -T git@github.com
sops decrypt secrets/secrets.yaml >/dev/null
```

Keep `SSH_AUTH_SOCK` available to the shell that runs Nix. The YubiKey stays on
the controller for the rest of the installation.

## 4. Select the disk deliberately

Inspect stable disk paths on the target:

```console
ssh nixos@<target-ip> 'lsblk -e7 -o NAME,SIZE,TYPE,MODEL,SERIAL,MOUNTPOINTS'
ssh nixos@<target-ip> 'ls -l /dev/disk/by-id/'
```

Replace `REPLACE-WITH-T14-DISK-ID` in `machines/t14/disko.nix` with the exact
whole-disk `/dev/disk/by-id/...` path. Do not use a partition path and do not
use a volatile name such as `/dev/nvme0n1`.

Review the diff and evaluate before proceeding:

```console
git diff -- machines/t14 flake.nix flake.lock
nix flake check
nix build .#nixosConfigurations.t14.config.system.build.toplevel
```

## 5. Create and enrol the persistent SOPS identity

Generate the installed host key on the controller, outside the repository. The
directory passed to `--extra-files` mirrors paths below the target root, so the
key lands directly in persistent `/data`:

```console
umask 077
T14_EXTRA_FILES="$(mktemp -d)"
install -d -m 0700 "$T14_EXTRA_FILES/data/etc/ssh"
ssh-keygen -q -t ed25519 -N '' \
  -f "$T14_EXTRA_FILES/data/etc/ssh/ssh_host_ed25519_key"
ssh-to-age \
  < "$T14_EXTRA_FILES/data/etc/ssh/ssh_host_ed25519_key.pub"
```

Keep this terminal open and retain `T14_EXTRA_FILES` until installation and
first-boot verification are complete.

Add the printed recipient to `.sops.yaml` as `&t14`, include `*t14` in the age
recipient list, and rekey every encrypted YAML file using the YubiKey:

```console
for secret_file in secrets/*.yaml; do
  sops updatekeys -y "$secret_file"
done

for secret_file in secrets/*.yaml; do
  sops decrypt "$secret_file" >/dev/null
done
```

Commit or otherwise preserve the new recipient and rekeyed secret files before
erasing the target. The private host key must never be added to Git or the Nix
store.

## 6. Install

Run nixos-anywhere from the controller. Its default phases kexec into a known
installer environment, run Disko, install NixOS, and reboot. Password prompts
for the temporary SSH login, LUKS system partition, and LUKS swap are expected.

Read the resolved disk path one final time:

```console
rg 'device = "/dev/disk/by-id/' machines/t14/disko.nix
```

Set the temporary installer password without saving it in shell history, then
run the installer:

```console
read -rs SSHPASS
export SSHPASS
nix run github:nix-community/nixos-anywhere -- \
  --flake .#t14 \
  --target-host nixos@<target-ip> \
  --env-password \
  --extra-files "$T14_EXTRA_FILES" \
  --generate-hardware-config nixos-generate-config \
  machines/t14/hardware.nix
```

Inspect the generated `machines/t14/hardware.nix` after the command. Disko owns
the filesystem and swap declarations; remove any generated duplicates if the
generator emitted them. Add only hardware settings confirmed for this T14.

## 7. Verify the first boot

After rebooting, verify the storage topology and SOPS identity:

```console
systemctl --failed
sudo test -r /run/secrets/users/cfi
findmnt / /nix /nix/store /cache /data
sudo btrfs subvolume list /
sudo ssh-keygen -y -f /data/etc/ssh/ssh_host_ed25519_key | ssh-to-age
```

The final recipient must match `&t14` in `.sops.yaml`. Reboot once more to test
Btrfs/LUKS unlock, encrypted swap, SOPS decryption, persistence, and root
rotation. Confirm that another entry appears below the `old-roots` subvolume.

Once verified, remove the temporary key material from the controller:

```console
rm -rf -- "$T14_EXTRA_FILES"
unset T14_EXTRA_FILES SSHPASS
```

Commit the generated hardware configuration and all enrollment changes.

## Existing machines

Disko is intentionally not part of the shared module list. `e14` continues to
use its manual filesystem configuration and is not affected. Never point the
`t14` nixos-anywhere command at an existing machine unless erasing it is the
explicit intent.
