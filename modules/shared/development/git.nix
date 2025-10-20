{ config, lib, pkgs, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs = {
        git = {
          enable = true;
          lfs.enable = true;

          userEmail = config.cfi2017.user.email;
          userName = config.cfi2017.user.fullName;

          extraConfig = {
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            pull.rebase = true;

            user.signingKey = "~/.ssh/id_ed25519.pub";

            safe.directory =
              "${config.cfi2017.user.homeDirectory}/${config.cfi2017.user.codeDir}/personal/nixos-config";

            gpg.format = "ssh";
            commit.gpgsign = true;
          };
        };

        lazygit = {
          enable = true;
          settings = { git = { commit = { signOff = true; }; }; };
        };

        gh = {
          enable = true;
          settings = {
            editor = "nvim";
            git_protocol = "ssh";
          };
        };
      };
    };
  };
}
