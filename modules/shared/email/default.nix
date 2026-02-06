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
in
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeDataLinks = [
            {
              directory = ".local/share/email";
              mode = "0700";
            }
          ];
          homeCacheLinks = [
          ];
          # homeCacheFileLinks = [".claude.json"];
        })
      ];
    })
    {
      home-manager = {
        users = {
          "${user}" =
            { ... }:
            {
              accounts.email.maildirBasePath = ".local/share/email";
              programs = {
                msmtp.enable = true;
                lieer.enable = true;
                neomutt = {
                  enable = true;
                  editor = "${pkgs.neovim}/bin/nvim";
                };
                notmuch = {
                  enable = true;
                  hooks = {
                    # preNew = "mbsync --all";
                  };
                };
              };
            };
        };
      };
    }
  ];
}
