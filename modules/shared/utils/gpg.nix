{ config, lib, pkgs, ... }: {
  options.cfi2017.gpg = {
    enable = lib.mkEnableOption "GPG key management with SOPS";
  };

  config = lib.mkIf config.cfi2017.gpg.enable {
    # Add GPG directory to persistent directories on Linux systems with persistence
    cfi2017.core.zfs =
      lib.mkIf (config.cfi2017.isLinux && config.cfi2017.persistence.enable) {
        homeDataLinks = [{
          directory = ".gnupg";
          mode = "0700";
        }];
      };

    # Add GPG package for Linux systems (Darwin gets it from homebrew)
    environment.systemPackages =
      lib.optionals config.cfi2017.isLinux [ pkgs.gnupg ];

    home-manager.users.${config.cfi2017.user.name} = {
      programs.gpg = {
        enable = true;
        settings = {
          trust-model = "tofu+pgp";
          # default-key = config.cfi2017.user.gpgKey;
          armor = true;
          with-fingerprint = true;
          keyid-format = "0xlong";
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
          personal-digest-preferences = "SHA512";
          cert-digest-algo = "SHA512";
          default-preference-list =
            "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
        };
      };

      services.gpg-agent = {
        enable = true;
        enableZshIntegration = true;
        pinentry.package = if config.cfi2017.isDarwin then
          null
        else if config.cfi2017.graphical.enable or false then
          pkgs.pinentry-gtk2
        else
          pkgs.pinentry-curses;
        extraConfig = lib.optionalString config.cfi2017.isDarwin ''
          pinentry-program /opt/homebrew/bin/pinentry-mac
        '' + lib.optionalString (config.cfi2017.isLinux
          && !(config.cfi2017.graphical.enable or false)) ''
            pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
          '';
      };

    };
  };
}
