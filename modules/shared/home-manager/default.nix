{
  config,
  options,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  user = config.cfi2017.user.name;
  flavor = config.cfi2017.colorScheme.flavor;
  accent = config.cfi2017.colorScheme.accent;
in
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeCacheLinks = [
            ".config"
            ".cache"
            ".local"
            ".claude"
          ];
          # homeCacheFileLinks = [".claude.json"];
        })
      ];
    })
    {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
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
              inputs.multi-profile.homeModules.default
            ];

            colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;

            home = {
              stateVersion = config.cfi2017.stateVersion;
              username = config.cfi2017.user.name;
              homeDirectory = config.cfi2017.user.homeDirectory;
              sessionVariables = {
                SOPS_AGE_KEY_FILE = config.cfi2017.user.homeDirectory + "/.config/sops/age/keys.txt";
              };
            };

            programs.home-manager.enable = true;
            programs.multiProfile = {
              enable = true;

              profiles = (inputs.private-work.browserProfiles or { }) // {
                personal = {
                  browser = "zen";
                  desktopName = "Personal (Zen)";
                  pins = [
                    {
                      url = "https://mail.proton.me";
                      title = "Mail";
                      essential = true;
                    }
                  ];
                };
              };

              defaultProfile = "personal";

              router.rules = (inputs.private-work.browserRouterRules or [ ]) ++ [
                {
                  profile = "personal";
                }
              ];
            };

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
