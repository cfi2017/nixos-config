{ config, lib, ... }: {
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = if config.cfi2017.isDarwin then
        "/Users/${config.cfi2017.user.name}/.config/sops/age/keys.txt"
      else
        "/home/${config.cfi2017.user.name}/.config/sops/age/keys.txt";

      # Only use SSH keys on Linux systems, Darwin relies solely on age keys
      sshKeyPaths = lib.optionals config.cfi2017.isLinux [
        (if config.cfi2017.persistence.enable then
          "${config.cfi2017.persistence.dataPrefix}/etc/ssh/ssh_host_ed25519_key"
        else
          "/etc/ssh/ssh_host_ed25519_key")
      ];

      generateKey = true;
    };

    secrets = lib.mkMerge [
      # Shared secrets (available on both Linux and Darwin)
      {
        openrouter_api_key = {
          owner = config.cfi2017.user.name;
          mode = "0600";
        };
      }

      # Linux-specific secrets
      (lib.mkIf config.cfi2017.isLinux {
        "users/cfi" = { neededForUsers = true; };

        "users/root" = { neededForUsers = true; };

        wireless = { };

        "authorized_keys/root" = { path = "/root/.ssh/authorized_keys"; };

        "authorized_keys/cfi" = {
          path = "${config.cfi2017.user.homeDirectory}/.ssh/authorized_keys";
          owner = config.cfi2017.user.name;
        };

        # GPG keys for Linux
        "gpg/private_key" = {
          path = "${config.cfi2017.user.homeDirectory}/.gnupg/private-key.asc";
          owner = config.cfi2017.user.name;
          mode = "0600";
        };

        "gpg/public_key" = {
          path = "${config.cfi2017.user.homeDirectory}/.gnupg/public-key.asc";
          owner = config.cfi2017.user.name;
          mode = "0644";
        };

        "gpg/trust_db" = {
          path = "${config.cfi2017.user.homeDirectory}/.gnupg/trust-db.txt";
          owner = config.cfi2017.user.name;
          mode = "0600";
        };
      })

      # Darwin-specific secrets
      (lib.mkIf config.cfi2017.isDarwin {
        "authorized_keys/cfi" = {
          path = "${config.cfi2017.user.homeDirectory}/.ssh/authorized_keys";
          owner = config.cfi2017.user.name;
        };

        # GPG keys for Darwin
        "gpg/private_key" = {
          path = "${config.cfi2017.user.homeDirectory}/.gnupg/private-key.asc";
          owner = config.cfi2017.user.name;
          mode = "0600";
        };

        "gpg/public_key" = {
          path = "${config.cfi2017.user.homeDirectory}/.gnupg/public-key.asc";
          owner = config.cfi2017.user.name;
          mode = "0644";
        };

        "gpg/trust_db" = {
          path = "${config.cfi2017.user.homeDirectory}/.gnupg/trust-db.txt";
          owner = config.cfi2017.user.name;
          mode = "0600";
        };
      })
    ];
  };
}
