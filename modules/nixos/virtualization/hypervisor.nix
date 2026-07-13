{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    cfi2017.development.virtualisation = {
      hypervisor.enable = lib.mkEnableOption "Libvirt/KVM";
    };
  };

  config = lib.mkIf config.cfi2017.development.virtualisation.hypervisor.enable {
    # /var/lib/libvirt holds the VM state (and the encrypted secrets dir).
    # /var/lib/systemd must persist too: libvirtd loads its secrets via
    # systemd `LoadCredentialEncrypted`, which decrypts with the host key at
    # /var/lib/systemd/credential.secret. Under impermanence that key is wiped
    # on every boot, so the persisted (already-encrypted) secret can no longer
    # be decrypted and libvirtd fails with status=243/CREDENTIALS. Persisting
    # the host key keeps the two in sync across reboots.
    cfi2017.core.zfs.systemCacheLinks = [
      "/var/lib/libvirt"
      "/var/lib/systemd"
    ];

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

    home-manager.users.cfi = {
      home.packages = with pkgs; [ virt-manager ];
    };

    users.users.cfi = {
      extraGroups = [ "libvirtd" ];
    };
  };
}
