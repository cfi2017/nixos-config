{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.cfi2017.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "cfi";
      description = "Primary user name";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Carlo Field";
      description = "User full name";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "carlo@swiss.dev";
      description = "User email address";
    };

    workEmail = lib.mkOption {
      type = lib.types.str;
      default = "carlo.field@adfinis.com";
      description = "Work email address";
    };

    gpgKey = lib.mkOption {
      type = lib.types.str;
      default = "52BFF6CCB1DA1915821F741BF29959D9BAB9798F";
      description = "User GPG key";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "User home directory";
    };

    codeDir = lib.mkOption {
      type = lib.types.str;
      description = "Projects / Code directory";
      default = "code";
    };

    shell = lib.mkOption {
      type = lib.types.str;
      default = "zsh";
      description = "Default shell";
    };

    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default editor";
    };
  };

  config = {
    cfi2017.user.homeDirectory = lib.mkDefault (
      if config.cfi2017.isDarwin then
        "/Users/${config.cfi2017.user.name}"
      else
        "/home/${config.cfi2017.user.name}"
    );

    users =
      # Add mutableUsers only on NixOS; nix-darwin does not have this option.
      (lib.optionalAttrs config.cfi2017.isLinux {
        mutableUsers = config.cfi2017.persistence.enable;
      })
      // {
        users.${config.cfi2017.user.name} = lib.mkMerge [
          # Base user configuration
          {
            home = config.cfi2017.user.homeDirectory;
          }
          # Linux-specific user configuration
          (lib.mkIf config.cfi2017.isLinux {
            isNormalUser = true;
            group = config.cfi2017.user.name;
            hashedPasswordFile = config.sops.secrets."users/${config.cfi2017.user.name}".path;
            extraGroups = lib.mkIf config.cfi2017.isLinux [
              "systemd-journal"
              "systemd-resolve"
              "wheel"
              "dialout"
            ];
          })
          # Darwin-specific user configuration (no extra fields needed)
        ];
        groups.${config.cfi2017.user.name} = { };
      };
  };
}
