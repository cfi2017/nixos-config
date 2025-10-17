{ config, lib, ... }: {
  options.cfi2017.services.sshd = {
    enable = lib.mkEnableOption "OpenSSH daemon";
  };

  config = lib.mkMerge [
    (lib.mkIf (config.cfi2017.isLinux && config.cfi2017.services.sshd.enable) {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          ensureSystemExists =
            [ "${config.cfi2017.persistence.dataPrefix}/etc/ssh" ];
        })
      ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "prohibit-password";

          # Remove stale sockets
          StreamLocalBindUnlink = "yes";
        };

        hostKeys = [
          {
            bits = 4096;
            path = if config.cfi2017.persistence.enable then
              "${config.cfi2017.persistence.dataPrefix}/etc/ssh/ssh_host_rsa_key"
            else
              "/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
          {
            bits = 4096;
            path = if config.cfi2017.persistence.enable then
              "${config.cfi2017.persistence.dataPrefix}/etc/ssh/ssh_host_ed25519_key"
            else
              "/etc/ssh/ssh_host_ed25519";
            type = "ed25519";
          }
        ];
      };
    })
  ];
}
