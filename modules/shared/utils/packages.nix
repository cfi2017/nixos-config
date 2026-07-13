{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = {
    # System Wide Packages
    environment.systemPackages = with pkgs; [
      wget
      curl
      coreutils
      unzip
      openssl
      dnsutils
      nmap
      util-linux
      whois
      moreutils
      git
      age
      sops
      ssh-to-age
      tcpdump
      nvd
      tree
      vim
      tlrc
      file
      wireguard-tools
      mumble
      openvpn
      trippy
      spotify
      bitwarden-cli
      gopass
      sshpass
      keepassxc
      lbdb
      citrix-workspace
      ccid
      pcsclite
      usbutils
      gitflow
      # telnet
      inetutils
      difftastic
      socat

      zammad-tui
      agx

      jetbrains.rust-rover

      # enshittification
      claude-code
      code-cursor

      comma

      # iphone stuff
      libimobiledevice
      libimobiledevice-glue
      usbmuxd
      f3d
      mesa-demos

      # binary analysis
      lurk
      ltrace
      strace
      strace-analyzer

      pcsc-safenet
    ];

    # User Packages
    home-manager.users.${config.cfi2017.user.name} = {
      home = {
        packages = with pkgs; [
          fontconfig
          fd
          jq
          yq-go
          direnv
          devenv
          atac
          comma
          autojump
          # inputs.nixvim.packages.${pkgs.system}.default
          ffmpeg
          z3
          glab
          gpgme
          gpgme.dev
          logseq

          # language servers
          bash-language-server
          rust-analyzer
          nil
          nixd
          helm-ls
          ruff
          basedpyright

          shell-gpt
        ];
      };
    };
  };
}
