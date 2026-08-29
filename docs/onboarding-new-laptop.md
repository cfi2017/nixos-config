# Onboarding a new NixOS laptop

This is the bootstrap path for a new laptop when the SOPS PGP key is available
on a YubiKey. The YubiKey is used to authorize the bootstrap; the installed
machine uses its own persistent SSH host key to decrypt secrets unattended.

> **Destructive step ahead:** storage setup erases the selected disk. Resolve
> the disk by its stable `/dev/disk/by-id/...` name and inspect it with `lsblk`
> immediately before changing partitions. Do not blindly reuse `nvme0n1` from
> an existing machine.

## 1. Boot and verify access

Boot a recent NixOS installer, connect to the network, plug in the YubiKey, and
open a root shell. Install the bootstrap tools into a temporary shell:

```console
nix shell nixpkgs#git nixpkgs#gnupg nixpkgs#sops nixpkgs#age nixpkgs#ssh-to-age
gpg --card-status
```

The SSH credential on this YubiKey is a resident FIDO2 key. Start an agent and
load resident credentials from the token; `-K` asks the authenticator for its
discoverable credentials and does not copy private key material off the token:

```console
eval "$(ssh-agent -s)"
ssh-add -K
ssh-add -l
```

Enter the YubiKey PIN and touch it when requested. `ssh-add -l` should now show
an `ED25519-SK` credential. Do not use `ssh-keygen -K` in the repository: that
command writes resident-key handle files into the current directory, whereas
`ssh-add -K` loads them directly into the agent.

Confirm both kinds of access before touching the disk:

```console
ssh -T git@github.com
git clone git@github.com:cfi2017/nixos-config.git
cd nixos-config
sops decrypt secrets/secrets.yaml >/dev/null
```

The first command may report that GitHub does not provide shell access; an
authentication-success message is what matters. SSH access is required not
only to clone this repository, but also to fetch its private `private-work` and
`ida-pro-flake` inputs. Keep this agent running and ensure `SSH_AUTH_SOCK` stays
visible in the shell used for all Nix commands. Expect a touch whenever the
resident credential signs an SSH authentication request.

If `ssh-add -K` finds no credentials, verify that the installer has a recent
OpenSSH build with security-key support and that the YubiKey's FIDO interface
is enabled. If the key loads but GitHub rejects it, register the public
`ED25519-SK` credential with GitHub or provision another temporary credential
before proceeding; the private flake inputs make SSH access mandatory.

If `gpg --card-status` works but SOPS cannot decrypt, check that the card
contains PGP key `44FE2A0A9B3796D2365E4A6FC292399AE67CE6F2`, which is the PGP
recipient declared in `.sops.yaml`.

## 2. Add the host configuration

Choose a short lowercase hostname. Create `machines/<hostname>/default.nix`
from `machines/e14/default.nix`, then review every host-specific setting:

- `networking.hostName` and the eight-hex-digit `networking.hostId` must be
  unique. Generate a host ID with `head -c 4 /dev/urandom | od -A none -t x4`.
- Set `cfi2017.stateVersion` and `system.stateVersion` to the NixOS release
  first installed on this machine; do not advance them during routine upgrades.
- Remove or change Intel, NVIDIA, fingerprint, swap-device, and kernel settings
  that do not match the new hardware.
- Keep `cfi2017.persistence.enable = true` only when using the ZFS layout below.

Add the host to `nixosConfigurations` in `flake.nix`, following the existing
`e14` entry:

```nix
<hostname> = nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs outputs;
    lib = lib "x86_64-linux";
  };
  modules = privateModules ++ sharedModules ++ nixosModules ++ [ ./machines/<hostname>/default.nix ];
};
```

## 3. Create and mount storage

This repository does not currently use Disko, so partitioning and ZFS dataset
creation are manual. The machine configuration expects this topology:

| Mount | Filesystem/dataset | Purpose |
| --- | --- | --- |
| `/boot` | FAT32, label `EFI` | EFI system partition |
| `/` | `rpool/local/root` | Ephemeral root; rolled back to `@blank` on boot |
| `/nix` | `rpool/local/nix` | Persistent Nix state |
| `/nix/store` | `rpool/local/nix-store` | Nix store |
| `/cache` | `rpool/local/cache` | Impermanence cache |
| `/data` | `rpool/safe/data` | Persistent system and home data |
| swap | LUKS mapping `cryptswap`, filesystem label `swap` | Encrypted swap/resume |

Create the partitions, encrypted `rpool`, datasets, and encrypted swap using
the new disk's stable by-id path. Create `rpool/local/root@blank` only after the
empty root dataset is ready and before installation writes to it. Mount the
datasets under `/mnt` according to the table, with `/mnt/data` available before
continuing.

Use stable paths in `machines/<hostname>/hardware.nix`. In particular, do not
copy `/dev/nvme0n1p3` from `e14`; use a by-UUID or by-partlabel path for the new
swap LUKS device. Generate the detected portion after mounting:

```console
mkdir -p machines/<hostname>
nixos-generate-config --root /mnt --show-hardware-config > machines/<hostname>/hardware.nix
```

Then merge back the ZFS, boot-loader, encrypted-swap, resume, and rollback
settings required by the topology. Verify the result before installation:

```console
findmnt -R /mnt
zfs list -r rpool
zfs list -t snapshot rpool/local/root@blank
```

## 4. Enrol the host for SOPS

The SOPS module reads the persistent Ed25519 host key from
`/data/etc/ssh/ssh_host_ed25519_key`. Generate it in the mounted target before
installation:

```console
install -d -m 0700 /mnt/data/etc/ssh
ssh-keygen -q -t ed25519 -N '' -f /mnt/data/etc/ssh/ssh_host_ed25519_key
ssh-to-age < /mnt/data/etc/ssh/ssh_host_ed25519_key.pub
```

Copy the printed `age1...` recipient into the `keys` section of `.sops.yaml`
under a clearly named anchor, then add that anchor to the creation rule's
`age` list. Rekey every encrypted YAML file while the YubiKey is attached:

```console
for secret_file in secrets/*.yaml; do
  sops updatekeys -y "$secret_file"
done
```

Touch the YubiKey when prompted. Confirm that every file now contains the new
recipient and remains decryptable:

```console
rg 'recipient: age1' secrets
for secret_file in secrets/*.yaml; do
  sops decrypt "$secret_file" >/dev/null
done
```

The separate `sops.age.keyFile` under the user's home is useful for interactive
secret editing after installation, but it is not the bootstrap identity. With
impermanence enabled, the persistent host key above is the reliable early-boot
identity used by this configuration.

## 5. Evaluate and install

Because the flake contains private SSH inputs, keep the YubiKey SSH agent
available during evaluation and installation:

```console
nix flake check
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
nixos-install --flake .#<hostname>
```

Commit and push the new machine definition, `.sops.yaml`, and rekeyed secret
files from the installer environment (or from another trusted machine) so the
configuration is recoverable before rebooting.

## 6. First-boot checks

Remove the installer and boot the new system. The ZFS passphrase and encrypted
swap may require credentials during early boot. Then verify:

```console
systemctl --failed
sudo test -r /run/secrets/users/cfi
sudo ssh-keygen -y -f /data/etc/ssh/ssh_host_ed25519_key |
  ssh-to-age
findmnt / /nix /nix/store /cache /data
```

The final `ssh-to-age` output must match the recipient added to `.sops.yaml`.
Also test a reboot: it proves that the host decryption key is persistent and
available early enough, and that root rollback does not remove required state.

Afterward, update `rebuild.sh`: it is currently hard-coded to `e14`. Either use
`nixos-rebuild switch --flake .#<hostname> --sudo` on the new laptop or make the
script select the current hostname before relying on it.
