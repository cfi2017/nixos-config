{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "attic.k8s.swiss.dev";
          protocol = "ssh-ng";
          sshUser = "root";
          # The daemon runs as root and needs an explicit identity.
          sshKey = "${config.cfi2017.user.homeDirectory}/.ssh/id_ed25519";
          system = "x86_64-linux";
        }
      ];
      settings.builders-use-substitutes = true;
    };

    # /etc/ssh/ssh_config also applies to connections made by nix-daemon.
    programs.ssh.extraConfig = ''
      Host attic.k8s.swiss.dev
        Port 20022
    '';
    programs.ssh.knownHosts.attic-builder = {
      hostNames = [ "[attic.k8s.swiss.dev]:20022" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3bVXJU1Mphb62jcerrlf31NPk3/nW/jXCu5m86Zp0J";
    };

    cfi2017.core.zfs = lib.mkMerge [
      (lib.mkIf (config.cfi2017.persistence.enable && config.cfi2017.isLinux) {
        systemDataLinks = [
          "/var/lib/nixos"
          "/var/lib/fprint"
        ];
      })
      (lib.mkIf (!config.cfi2017.persistence.enable && config.cfi2017.isLinux) { })
    ];

    system = {
      autoUpgrade = {
        enable = lib.mkDefault true;
        flake = "github:cfi2017/nixos-config";
        dates = "01/04:00";
        randomizedDelaySec = "15min";
      };
    };

    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      doas = {
        enable = true;
        extraRules = [
          {
            users = [ config.cfi2017.user.name ];
            noPass = true;
          }
        ];
      };

      polkit = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      lshw
      bridge-utils
      intel-ocl
    ];

    services = {
      fwupd = {
        enable = true;
      };
    };
  };
}
