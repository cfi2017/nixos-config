{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.cfi2017.core = {
    zfs = {
      # Enable ZFS
      enable = lib.mkEnableOption "zfs";
      # Ask for credentials
      encrypted = lib.mkEnableOption "zfs request credentials";

      # Clear our symbolic links
      systemCacheLinks = lib.mkOption {
        default = [ ];
        description = "List of system cache directories to persist";
      };
      systemDataLinks = lib.mkOption {
        default = [ ];
        description = "List of system data directories to persist";
      };
      homeCacheLinks = lib.mkOption {
        default = [ ];
        description = "List of home cache directories to persist";
      };
      homeCacheFileLinks = lib.mkOption {
        default = [ ];
        description = "List of home cache files to persist";
      };
      homeDataLinks = lib.mkOption {
        default = [ ];
        description = "List of home data directories to persist";
      };

      ensureSystemExists = lib.mkOption {
        default = [ ];
        example = [ "/data/etc/ssh" ];
        description = "List of system directories to ensure exist on boot";
      };
      ensureHomeExists = lib.mkOption {
        default = [ ];
        example = [ ".ssh" ];
        description = "List of home directories to ensure exist on boot";
      };
      rootDataset = lib.mkOption {
        default = "";
        example = "rpool/local/root";
        description = "ZFS root dataset for rollback functionality";
      };
    };
  };

  config = {
    cfi2017 = {
      core = {
        zfs = {
          enable = lib.mkDefault true;
        };
      };
    };

    environment.persistence."${config.cfi2017.persistence.cachePrefix}" =
      lib.mkIf config.cfi2017.persistence.enable
        {
          hideMounts = true;
          directories = config.cfi2017.core.zfs.systemCacheLinks;
          users.cfi.directories = config.cfi2017.core.zfs.homeCacheLinks;
          users.cfi.files = config.cfi2017.core.zfs.homeCacheFileLinks;
        };

    environment.persistence."${config.cfi2017.persistence.dataPrefix}" =
      lib.mkIf config.cfi2017.persistence.enable
        {
          hideMounts = true;
          directories = config.cfi2017.core.zfs.systemDataLinks;
          users.cfi.directories = config.cfi2017.core.zfs.homeDataLinks;
        };

    boot = lib.mkIf config.cfi2017.core.zfs.enable {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/";
        requestEncryptionCredentials = config.cfi2017.core.zfs.encrypted;
      };
      #initrd.postDeviceCommands = lib.mkIf (config.cfi2017.persistence.enable
      #  && config.cfi2017.core.zfs.rootDataset != "") (lib.mkAfter ''
      #    zfs rollback -r ${config.cfi2017.core.zfs.rootDataset}@blank
      #  '');

      initrd.systemd.services.rollback-root =
        lib.mkIf (config.cfi2017.persistence.enable && config.cfi2017.core.zfs.rootDataset != "")
          {
            description = "Rollback ZFS root dataset to blank";
            wantedBy = [ "initrd.target" ];
            after = [ "zfs-import.target" ];
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              zfs rollback -r ${config.cfi2017.core.zfs.rootDataset}@blank
            '';
          };
    };

    services = lib.mkIf config.cfi2017.core.zfs.enable {
      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
    };

    environment.systemPackages =
      lib.mkIf
        (
          config.cfi2017.core.zfs.enable
          && config.cfi2017.persistence.enable
          && config.cfi2017.core.zfs.rootDataset != ""
        )
        [
          (pkgs.writeScriptBin "zfsdiff" ''
            doas zfs diff ${config.cfi2017.core.zfs.rootDataset}@blank -F | ${pkgs.ripgrep}/bin/rg -e "\+\s+/\s+" | cut -f3- | ${pkgs.skim}/bin/sk --query "/home/cfi/"
          '')
        ];

    system.activationScripts = lib.mkIf config.cfi2017.persistence.enable (
      let
        ensureSystemExistsScript = lib.concatStringsSep "\n" (
          map (path: ''mkdir -p "${path}"'') config.cfi2017.core.zfs.ensureSystemExists
        );
        ensureHomeExistsScript = lib.concatStringsSep "\n" (
          map (path: ''
            mkdir -p "/home/cfi/${path}"; chown cfi:users /home/cfi/${path}
          '') config.cfi2017.core.zfs.ensureHomeExists
        );
      in
      {
        ensureSystemPathsExist = {
          text = ensureSystemExistsScript;
          deps = [ ];
        };
        ensureHomePathsExist = {
          text = ''
            mkdir -p /home/cfi/
            ${ensureHomeExistsScript}
          '';
          deps = [
            "users"
            "groups"
          ];
        };
      }
    );
  };
}
