{
  # Disko generates the device and filesystem type. These flags are required
  # by impermanence and preserve the boot ordering of the existing hosts.
  fileSystems = {
    "/".neededForBoot = true;
    "/nix".neededForBoot = true;
    "/nix/store".neededForBoot = true;
    "/cache".neededForBoot = true;
    "/data".neededForBoot = true;
  };

  disko.devices.disk.system = {
    # KIOXIA KBG6AZNV512G, serial 5E9PSQGBZ12L. This whole-disk EUI was
    # verified from the T14 installer before enrollment.
    device = "/dev/disk/by-id/nvme-eui.8ce38e0404d8a302";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
            extraArgs = [
              "-n"
              "EFI"
            ];
          };
        };
        swap = {
          # Review against installed RAM before enrollment. Hibernation needs
          # enough swap to hold memory.
          size = "64G";
          content = {
            type = "luks";
            name = "cryptswap";
            askPassword = true;
            settings.allowDiscards = true;
            content = {
              type = "swap";
              resumeDevice = true;
              extraArgs = [
                "-L"
                "swap"
              ];
            };
          };
        };
        system = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptsystem";
            askPassword = true;
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "nixos"
              ];
              subvolumes = {
                # `blank` is the permanent pristine template. At boot the
                # initrd archives `root` and snapshots `blank` into a new root.
                blank = { };
                root = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                nix = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "nix-store" = {
                  mountpoint = "/nix/store";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                cache = {
                  mountpoint = "/cache";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                data = {
                  mountpoint = "/data";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "old-roots" = { };
              };
            };
          };
        };
      };
    };
  };
}
