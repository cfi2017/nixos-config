{ pkgs, lib, config, ... }: {
  options = {
    cfi2017.development.virtualisation = {
      hypervisor.enable = lib.mkEnableOption "Libvirt/KVM";
    };
  };

  config =
    lib.mkIf config.cfi2017.development.virtualisation.hypervisor.enable {
      cfi2017.core.zfs.systemCacheLinks = [ "/var/lib/libvirt" ];

      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          verbatimConfig = ''
            nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
          '';
          runAsRoot = false;
        };

        onBoot = "start";
        onShutdown = "shutdown";
      };

      home-manager.users.cfi = { home.packages = with pkgs; [ virt-manager ]; };

      users.users.cfi = { extraGroups = [ "libvirtd" ]; };
    };
}
