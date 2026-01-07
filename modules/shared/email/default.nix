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
                    preNew = "mbsync --all";
                  };
                };
              };

              accounts.email.accounts = {
                "sample" = {
                  address = "";
                  gpg = {
                    key = "";
                    signByDefault = "";
                  };

                  flavor = "gmail.com";

                  lieer = {
                    enable = true;
                    sync = {
                      enable = true;
                    };
                  };
                  mbsync = {
                    enable = false;
                    create = "maildir";
                  };
                  msmtp.enable = true;
                  notmuch.enable = true;
                  primary = true;
                  realName = "";
                  signature = {
                    text = '''';
                    showSignature = "append";
                  };
                  passwordCommand = "mail-password";
                  userName = config.sops.secrets."email/${config.cfi2017.email.accounts.one.name}".path;
                };
              };
            };
        };
      };
    }
  ];
}
