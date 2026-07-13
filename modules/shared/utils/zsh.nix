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
          systemCacheLinks = [
            "/root/.local/share/autojump"
            "/var/lib/cloudflare-warp"
          ];
          homeCacheLinks = [ ".local/share/autojump" ];
        })
      ];
    })
    {
      programs.zsh.enable = true;

      home-manager.users.${config.cfi2017.user.name} = {
        programs.zsh = {
          enable = true;
          # Keep ~/.zshrc in $HOME (the pre-26.05 default). home-manager will
          # otherwise move it to ~/.config/zsh once stateVersion crosses 26.05.
          dotDir = config.cfi2017.user.homeDirectory;
          autosuggestion = {
            enable = true;
          };

          oh-my-zsh = {
            enable = true;
            plugins = [
              "aliases"
              "common-aliases"
              "fzf"
              "git"
              "gitignore"
              "history-substring-search"
              "helm"
              "kubectl"
              "ssh-agent"
              "urltools"
            ];
            theme = "bira";
          };
          initContent = "zmodload zsh/zprof";

          # defaultKeymap = "emacs";

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
            NIXPKGS_ALLOW_UNFREE = "1";
          };

          shellAliases = {
            config = "cd ~/code/personal/nixos-config";
            rebuild = "nixos-rebuild switch --flake ~/code/personal/nixos-config#e14 --sudo";
            cat = "bat -p --no-pager";
            # man = "tlrc";
            # grep = "rg";
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

            # Kubernetes aliases
            k = "kubectl";
          };
        };
      };
    }
  ];
}
