{ config, lib, pkgs, ... }: {
  config = {
    cfi2017.core.zfs = lib.mkMerge [
      (lib.mkIf (config.cfi2017.persistence.enable && config.cfi2017.isLinux) {
        systemDataLinks = [ "/var/lib/nixos" ];
      })
      (lib.mkIf (!config.cfi2017.persistence.enable && config.cfi2017.isLinux)
        { })
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
      sudo = { enable = false; };

      doas = {
        enable = true;
        extraRules = [{
          users = [ config.cfi2017.user.name ];
          noPass = true;
        }];
      };

      polkit = { enable = true; };
    };

    environment.systemPackages = with pkgs; [ lshw bridge-utils ];

    services = { fwupd = { enable = true; }; };

    i18n = {
      defaultLocale = "de_CH.UTF-8";
      extraLocaleSettings = {
        LC_ALL = "de_CH.UTF-8";
        LANGUAGE = "en_US.UTF-8";
        LC_TIME = "de_CH.UTF-8";
      };
      supportedLocales = [
        "de_CH.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
        "en_IE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
    };
  };
}
