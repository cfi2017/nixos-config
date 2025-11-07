{
  pkgs,
  config,
  options,
  inputs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          systemCacheLinks = [ "/root/.local/share/autojump" ];
          homeCacheLinks = [ ".local/share/autojump" ];
        })
      ];
    })
    {
      programs.zsh.enable = true;

      home-manager.users.${config.cfi2017.user.name} = {
        programs.zsh = {
          enable = true;
          autosuggestion = {
            enable = true;
          };

          # https://github.com/catppuccin/zsh-syntax-highlighting/blob/main/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh

          enableCompletion = true;
          plugins = [
            {
              name = "zsh-nix-shell";
              file = "nix-shell.plugin.zsh";
              src = pkgs.fetchFromGitHub {
                owner = "chisui";
                repo = "zsh-nix-shell";
                rev = "v0.8.0";
                sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
              };
            }
          ];

          syntaxHighlighting = {
            enable = true;
            highlighters = [
              "main"
              "cursor"
            ];
            styles = {
              comment = "fg=#5b6078";
              alias = "fg=#a6da95";
              suffix-alias = "fg=#a6da95";
              global-alias = "fg=#a6da95";
              function = "fg=#a6da95";
              command = "fg=#a6da95";
              precommand = "fg=#a6da95,italic";
              autodirectory = "fg=#f5a97f,italic";
              single-hyphen-option = "fg=#f5a97f";
              double-hyphen-option = "fg=#f5a97f";
              back-quoted-argument = "fg=#c6a0f6";
              builtin = "fg=#a6da95";
              reserved-word = "fg=#a6da95";
              hashed-command = "fg=#a6da95";
              commandseparator = "fg=#ed8796";
              command-substitution-delimiter = "fg=#cad3f5";
              command-substitution-delimiter-unquoted = "fg=#cad3f5";
              process-substitution-delimiter = "fg=#cad3f5";
              back-quoted-argument-delimiter = "fg=#ed8796";
              back-double-quoted-argument = "fg=#ed8796";
              back-dollar-quoted-argument = "fg=#ed8796";
              command-substitution-quoted = "fg=#eed49f";
              command-substitution-delimiter-quoted = "fg=#eed49f";
              single-quoted-argument = "fg=#eed49f";
              single-quoted-argument-unclosed = "fg=#ee99a0";
              double-quoted-argument = "fg=#eed49f";
              double-quoted-argument-unclosed = "fg=#ee99a0";
              rc-quote = "fg=#eed49f";
              dollar-quoted-argument = "fg=#cad3f5";
              dollar-quoted-argument-unclosed = "fg=#ee99a0";
              dollar-double-quoted-argument = "fg=#cad3f5";
              assign = "fg=#cad3f5";
              named-fd = "fg=#cad3f5";
              numeric-fd = "fg=#cad3f5";
              unknown-token = "fg=#ee99a0";
              path = "fg=#cad3f5,underline";
              path_pathseparator = "fg=#ed8796,underline";
              path_prefix = "fg=#cad3f5,underline";
              path_prefix_pathseparator = "fg=#ed8796,underline";
              globbing = "fg=#cad3f5";
              history-expansion = "fg=#c6a0f6";
              back-quoted-argument-unclosed = "fg=#ee99a0";
              redirection = "fg=#cad3f5";
              arg0 = "fg=#cad3f5";
              default = "fg=#cad3f5";
              cursor = "fg=#cad3f5";
            };
          };

          autocd = true;
          history = {
            expireDuplicatesFirst = true;
            path =
              if config.cfi2017.persistence.enable then
                "${config.cfi2017.persistence.dataPrefix}/home/${config.cfi2017.user.name}/.local/share/zsh/zsh_history"
              else
                "${config.cfi2017.user.homeDirectory}/.local/share/zsh/zsh_history";
          };

          sessionVariables = {
            DEFAULT_USER = config.cfi2017.user.name;
            PATH =
              if config.cfi2017.isDarwin then
                "/opt/homebrew/bin:/Users/${config.cfi2017.user.name}/Library/Python/3.9/bin:$PATH"
              else
                "$PATH";
            GPG_TTY = "$(tty)";
          };

          shellAliases = {
            home = "cd ~/";
            config = "cd ~/code/personal/nixos-config";
            work = "cd ~/code/work";
            personal = "cd ~/code/personal";
            gcl = "git clone";
            cat = "bat";
            ls = "eza --icons --group-directories-first";
            # man = "tlrc";
            ll = "eza --icons --group-directories-first -lah";
            grep = "rg";
            top = "btm";
            cls = "clear";
            myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";
            lg = "lazygit";
            find = "fd";

            # Directory traversal
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";
            "......" = "cd ../../../../..";

            ## Neovim aliases
            vim = "nvim";
            vi = "nvim";
            v = "nvim";

            # Nix aliases
            nhds = "nh darwin switch --hostname";
            nhos = "nh os switch --hostname";

            # Kubernetes aliases
            k = "kubectl";

            # Docker aliases
            d = "docker";
            dps = "docker ps";
            dpsa = "docker ps -a";
            di = "docker images";
            dexec = "docker exec";
            ds = "docker stop";
            drm = "docker rm";

          };
        };
      };
    }
  ];
}
