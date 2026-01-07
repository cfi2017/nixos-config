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

      # iphone stuff
      libimobiledevice
      libimobiledevice-glue
      usbmuxd

      # binary analysis
      lurk
      ltrace
      strace
      strace-analyzer
    ];

    # User Packages
    home-manager.users.${config.cfi2017.user.name} = {
      home = {
        packages = with pkgs; [
          fontconfig
          fd
          jq
          yq
          direnv
          devenv
          atac
          comma
          autojump
          # inputs.nixvim.packages.${pkgs.system}.default
          ffmpeg
          z3

          # language servers
          bash-language-server
          rust-analyzer
          nil
          nixd
          helm-ls
          ruff
          basedpyright
        ];
      };
    };
  };
}
