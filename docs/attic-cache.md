# Attic cache and remote builds

The SSH builder compiles missing outputs. Attic stores outputs for later reuse
by laptops, CI, and the builder itself. Configuring a builder does not upload its
outputs to Attic automatically.

## Enable authenticated downloads

Install the client with the next rebuild. If you have not created a cache yet,
use an administrative Attic login to run `attic cache create nixos`. Cache names
are independent of the server hostname; the examples below use `nixos`.
Run `attic cache info nixos` to obtain its signing public key.

Add this to the desired machine configuration:

```nix
cfi2017.attic = {
  enable = true;
  cache = "nixos";
  publicKey = "nixos:REPLACE_WITH_ACTUAL_PUBLIC_KEY";
};
```

Edit `secrets/secrets.yaml` with `sops secrets/secrets.yaml` and add:

```yaml
attic:
  token: YOUR_PULL_TOKEN
```

Use a cache-scoped token with pull permission. Keep the server's token-signing
key and administrative token on the server. For example, on the Attic server,
using its existing configuration/signing credentials:

```sh
atticadm make-token --sub laptops --validity '1 year' --pull nixos
atticadm make-token --sub builder --validity '1 year' --pull nixos --push nixos
```

Rebuild after adding the encrypted secret. SOPS renders a root-readable netrc
for the Nix daemon and a user-readable Attic client configuration at runtime.
The token stays out of the Nix store. The user token is readable by root too.
Existing public caches remain configured. Do not run `attic use`: NixOS manages
these settings declaratively. Do not run `attic login swiss` over the managed
client configuration; change the SOPS token instead.

The T14 enables the private `efi-nixos` cache. Other machines can opt in with
the same settings and a suitable SOPS token. The client package is installed
even while the module is disabled. Renew expiring tokens in SOPS.

## Publish selected outputs

On a machine with a pull/push token and an Attic client login/configuration:

```sh
# Upload the active system and its runtime closure after a successful rebuild.
attic push swiss:nixos /run/current-system

# Or upload a package and its runtime closure.
nix build nixpkgs#hello
attic push swiss:nixos ./result
```

Attic traverses references automatically and normally skips paths available in
upstream caches such as cache.nixos.org. A system closure covers the running
system, not every compiler/build dependency used to produce it.

For a build initiated on a laptop and executed remotely, the result is copied
back to the laptop. Pushing `/run/current-system` on that laptop is therefore
sufficient to publish the resulting system, regardless of where compilation ran.

## Publish continuously on the builder

Prefer one uploader on the build server. Give it the builder's cache-scoped
pull/push token. Configure an Attic server named `swiss` there, with its token in
a runtime secret file (or a SOPS-rendered client config as above), and run:

```sh
attic watch-store swiss:nixos
```

For a NixOS builder, a systemd service can supervise it:

```nix
systemd.services.attic-watch-store = {
  description = "Upload new builder store paths to Attic";
  wantedBy = [ "multi-user.target" ];
  wants = [ "network-online.target" ];
  after = [ "network-online.target" ];
  environment.XDG_CONFIG_HOME = "/run/attic-uploader";
  serviceConfig = {
    ExecStart = "${pkgs.attic-client}/bin/attic watch-store swiss:nixos";
    Restart = "always";
    RestartSec = "15s";
  };
};
```

Provide `/run/attic-uploader/attic/config.toml` through that server's secret
manager, mode 0400 and owned by root, with this content:

```toml
default-server = "swiss"
[servers.swiss]
endpoint = "https://attic.k8s.swiss.dev/"
token = "BUILDER_PULL_PUSH_TOKEN"
```

The watcher uploads new valid store paths while running, including build
dependencies and downloads not filtered as upstream. It does not backfill paths
that existed before startup or guarantee recovery of uploads missed during an
outage. Seed useful existing closures explicitly with `attic push`. For CI,
explicitly push successful job outputs as well, so upload failures are visible.
Choose the watcher if you want broad reuse of intermediate build dependencies;
choose explicit output pushes if you want tighter control over cache contents.

Configure the builder itself to pull from the same cache with the signing key
and runtime netrc. The laptop's `builders-use-substitutes` tells the remote
builder to use its own configured substituters; it does not forward the laptop's
cache credentials or configure the remote machine.

Keep normal cache.nixos.org access on all machines. Attic is most useful for
custom packages, overlay changes, and outputs missing from upstream caches.
Reuse requires matching derivations (inputs, system, and build configuration).
Retention on the Attic server and Nix garbage collection on the builder are
separate policies. Size Attic retention around how often you rebuild; deleting
an old laptop generation does not remove its uploaded cache paths immediately.

## Verify

```sh
attic cache info swiss:nixos
nix config show substituters
nix config show trusted-public-keys
sudo test -r /run/secrets/rendered/attic-netrc
```

To test a real cache hit without deleting an active system, choose an uploaded
store path absent on another configured machine and run `nix-store --realise`
on that path there; Nix should report copying it from the Attic URL.

References: [Attic tutorial](https://docs.attic.rs/tutorial.html),
[store watcher implementation](https://github.com/zhaofengli/attic/blob/main/client/src/command/watch_store.rs).
