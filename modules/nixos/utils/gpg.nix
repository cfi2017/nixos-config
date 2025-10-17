{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.cfi2017.gpg.enable {
    # Enable GPG agent as a system service
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Ensure GPG directories exist at boot
    systemd.tmpfiles.rules = [
      "d /home/${config.cfi2017.user.name}/.gnupg 0700 ${config.cfi2017.user.name} ${config.cfi2017.user.name}"
    ];
  };
}
