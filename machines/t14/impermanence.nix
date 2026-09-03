{ pkgs, ... }:
{
  boot = {
    supportedFilesystems = [ "btrfs" ];
    initrd.systemd.services.rotate-impermanent-root = {
      description = "Archive the previous Btrfs root and create a clean root";
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-cryptsetup@cryptsystem.service" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      path = [
        pkgs.btrfs-progs
        pkgs.coreutils
        pkgs.util-linux
      ];
      script = ''
        mountpoint=/run/btrfs-root
        mkdir -p "$mountpoint"
        mount -t btrfs -o subvol=/ /dev/mapper/cryptsystem "$mountpoint"

        if [ -e "$mountpoint/root" ]; then
          archived="$mountpoint/old-roots/$(date +%s-%N)"
          mv "$mountpoint/root" "$archived"
          touch "$archived"
        fi

        btrfs subvolume snapshot "$mountpoint/blank" "$mountpoint/root"

        find "$mountpoint/old-roots" -mindepth 1 -maxdepth 1 -mtime +14 \
          -exec btrfs subvolume delete {} \; || true

        umount "$mountpoint"
      '';
    };
  };
}
