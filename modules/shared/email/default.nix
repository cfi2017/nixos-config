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
              programs = {
                mbsync.enable = true;
                msmtp.enable = true;
                lieer.enable = true;
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
