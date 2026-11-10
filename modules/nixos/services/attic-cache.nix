{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cfi2017.attic;
  clientConfigPath = config.sops.templates.attic-client.path;
in
{
  options.cfi2017.attic = {
    enable = lib.mkEnableOption "authenticated Attic binary cache";
    cache = lib.mkOption {
      type = lib.types.str;
      description = "Name of the cache on attic.k8s.swiss.dev.";
    };
    publicKey = lib.mkOption {
      type = lib.types.str;
      description = "Cache signing public key from attic cache info.";
    };
    tokenSecret = lib.mkOption {
      type = lib.types.str;
      default = "attic/token";
      description = "SOPS secret containing a pull token, or pull/push token for interactive uploads.";
    };
  };

  config = lib.mkMerge [
    { environment.systemPackages = [ pkgs.attic-client ]; }
    (lib.mkIf cfg.enable {
      sops.secrets.${cfg.tokenSecret} = {
        owner = config.cfi2017.user.name;
        mode = "0400";
      };
      sops.templates.attic-netrc = {
        mode = "0400";
        content = ''
          machine attic.k8s.swiss.dev
          password ${config.sops.placeholder.${cfg.tokenSecret}}
        '';
      };
      nix.settings = {
        substituters = [ "https://attic.k8s.swiss.dev/${cfg.cache}" ];
        trusted-public-keys = [ cfg.publicKey ];
        netrc-file = config.sops.templates.attic-netrc.path;
      };
      # Render credentials at activation time, never into the Nix store.
      sops.templates.attic-client = {
        owner = config.cfi2017.user.name;
        mode = "0400";
        content = ''
          default-server = "swiss"
          [servers.swiss]
          endpoint = "https://attic.k8s.swiss.dev/"
          token = "${config.sops.placeholder.${cfg.tokenSecret}}"
        '';
      };
      home-manager.users.${config.cfi2017.user.name} = { config, ... }: {
        xdg.configFile."attic/config.toml".source = config.lib.file.mkOutOfStoreSymlink clientConfigPath;
      };
    })
  ];
}
