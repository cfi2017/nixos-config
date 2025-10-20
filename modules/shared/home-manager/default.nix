{ config, options, inputs, lib, pkgs, ... }:
let
  user = config.cfi2017.user.name;
  flavor = config.cfi2017.colorScheme.flavor;
  accent = config.cfi2017.colorScheme.accent;
in {
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeCacheLinks = [ ".config" ".cache" ".local" ];
        })
      ];
    })
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        # Fix for file conflicts during darwin-rebuild/home-manager activation
        backupFileExtension = "backup";
        users = {
          "${user}" = { ... }: {
            # Common config
            imports = [
              inputs.catppuccin.homeModules.catppuccin
              inputs.nix-colors.homeManagerModules.default
              inputs.zen-browser.homeModules.twilight-official
            ];

            colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;

            home = {
              stateVersion = config.cfi2017.stateVersion;
              username = config.cfi2017.user.name;
              homeDirectory = config.cfi2017.user.homeDirectory;
              sessionVariables = {
                SOPS_AGE_KEY_FILE = config.cfi2017.user.homeDirectory
                  + "/.config/sops/age/keys.txt";
              };
            };

            programs.home-manager.enable = true;

            # User-specific catppuccin configuration
            catppuccin = {
              enable = true;
              flavor = flavor;
              accent = accent;
            };

          };
        };
      };
    }
  ];
}
