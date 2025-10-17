{ lib, config, pkgs, ... }: {
  options = {
    cfi2017.isLinux = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = "Whether the host is a Linux system.";
    };

    cfi2017.isDarwin = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = "Whether the host is a Darwin system.";
    };

    cfi2017.font = lib.mkOption {
      type = lib.types.str;
      description = "Default font for the system.";
    };

    cfi2017.colorScheme.flavor = lib.mkOption {
      type = lib.types.str;
      description = "Default flavor for the color scheme.";
      default = "macchiato";
    };

    cfi2017.colorScheme.accent = lib.mkOption {
      type = lib.types.str;
      description = "Default accent for the color scheme.";
      default = "peach";
    };

    # System version option
    cfi2017.stateVersion = lib.mkOption {
      type = lib.types.str;
      example = "25.05";
      description = "NixOS state version";
    };

    cfi2017.timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Zurich";
      description = "Time zone for the system.";
    };

    # Impermanence options
    cfi2017.persistence = {
      enable = lib.mkEnableOption "Enable persistence/impermanence";

      dataPrefix = lib.mkOption {
        type = lib.types.str;
        default = "/data";
        description = "Prefix for persistent data storage";
      };

      cachePrefix = lib.mkOption {
        type = lib.types.str;
        default = "/cache";
        description = "Prefix for persistent cache storage";
      };
    };

    # Stub for core namespace so that shared modules referencing
    # `cfi2017.core.*` options are accepted when running on platforms
    # that do not import the Linux-specific ZFS module.
    cfi2017.core = lib.mkOption {
      type = lib.types.submodule { };
      default = { };
      description = "Namespace for Linux-only core settings. Empty on Darwin.";
    };
  };

  config = {
    cfi2017.isLinux = lib.cfi2017.isLinux;
    cfi2017.isDarwin = lib.cfi2017.isDarwin;
    cfi2017.font =
      if lib.cfi2017.isDarwin then "0xProto" else "0xProto Nerd Font";

    # Enable persistence by default only on Linux systems
    # This can be overridden per-machine as needed
    cfi2017.persistence.enable = lib.mkDefault config.cfi2017.isLinux;
  };
}
