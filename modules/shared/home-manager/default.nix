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
          # `.claude.json` is kept inside ~/.claude via CLAUDE_CONFIG_DIR (see
          # sessionVariables below), so the whole directory persists as one unit.
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
                # Keep Claude Code's global config (`.claude.json`: login, project
                # history, resumable chats) inside the already-persisted ~/.claude
                # directory instead of ~/.claude.json in the ephemeral home root.
                # Persisting the whole directory (rather than bind-mounting the
                # single file) also survives Claude's atomic writes cleanly.
                CLAUDE_CONFIG_DIR = config.cfi2017.user.homeDirectory + "/.claude";
              };
            };

            programs.home-manager.enable = true;
            programs.multiProfile = {
              enable = true;

              profiles = (inputs.private-work.browserProfiles or { }) // {
                personal = {
                  browser = "zen";
                  pins = [
                    {
                      url = "https://mail.proton.me";
                      title = "Mail";
                      essential = true;
                    }
                  ];
                };
                shc = {
                  browser = "zen";
                  pins = [
                    {
                      url = "https://mail.google.com";
                      title = "Mail";
                      essential = true;
                    }
                  ];
                };
              };

              defaultProfile = "personal";

              # The catch-all is expressed by defaultProfile below; a rule with no
              # host patterns is ignored by the router (and warns), so don't add one.
              router.rules = inputs.private-work.browserRouterRules or [ ];
            };

            # User-specific catppuccin configuration
            catppuccin = {
              enable = true;
              # Pin current behavior: `enable` will become a global toggle and
              # `autoEnable` will drive per-port enrollment in a future release.
              autoEnable = true;
              flavor = flavor;
              accent = accent;
            };
          };
        };
      };
    }
  ];
}
