{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cfi2017.backup.rustic;
  encryptedPasswordFile =
    if cfg.encryptedPasswordFile == null then "/dev/null" else toString cfg.encryptedPasswordFile;

  # Impermanence keeps the real data below each persistence root. Backing up
  # the roots instead of their bind-mounted destinations avoids crossing the
  # ephemeral root and automatically includes paths added by any module.
  persistenceRoots = lib.attrNames (
    lib.filterAttrs (_: persistence: persistence.enable) config.environment.persistence
  );

  passwordCommand = pkgs.writeShellScript "rustic-password-from-age" ''
    exec ${lib.getExe pkgs.rage} --decrypt \
      --identity ${lib.escapeShellArg cfg.hostIdentityFile} \
      ${lib.escapeShellArg encryptedPasswordFile}
  '';

in
{
  options.cfi2017.backup.rustic = {
    enable = lib.mkEnableOption "scheduled Rustic backups of impermanence data";

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "systemd OnCalendar expression for the backup timer.";
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      description = "Maximum random delay applied to scheduled backups.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      default = "backup/rustic/environment";
      description = ''
        SOPS secret containing an EnvironmentFile with the Rustic repository
        and S3 credentials. The repository password is handled separately.
      '';
    };

    encryptedPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = lib.literalExpression "../../../secrets/t14-rustic-password.age";
      description = ''
        Path to a separately recoverable age-encrypted Rustic repository
        password. It should be encrypted only to this host and the selected
        YubiKeys. The ciphertext is safe to store with the Nix configuration.
      '';
    };

    hostIdentityFile = lib.mkOption {
      type = lib.types.str;
      default = config.sops.age.keyFile;
      defaultText = lib.literalExpression "config.sops.age.keyFile";
      description = "Runtime age identity used by this host to unlock the repository password.";
    };

    forgetArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--keep-daily"
        "7"
        "--keep-weekly"
        "5"
        "--keep-monthly"
        "12"
      ];
      description = "Arguments passed to `rustic forget --prune` after a successful backup.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.cfi2017.persistence.enable;
        message = "cfi2017.backup.rustic requires cfi2017.persistence.enable";
      }
      {
        assertion = persistenceRoots != [ ];
        message = "cfi2017.backup.rustic found no enabled environment.persistence roots";
      }
      {
        assertion = cfg.encryptedPasswordFile != null;
        message = "cfi2017.backup.rustic.encryptedPasswordFile must point to the age-encrypted repository password";
      }
    ];

    sops.secrets.${cfg.secretName} = {
      mode = "0400";
      owner = "root";
      restartUnits = [ "rustic-backup.service" ];
    };

    environment.systemPackages = [
      pkgs.age-plugin-yubikey
      pkgs.rage
      pkgs.rustic
    ];

    systemd.services.rustic-backup = {
      description = "Back up impermanence data with Rustic";
      after = [ "local-fs.target" ];
      unitConfig.RequiresMountsFor = persistenceRoots;

      path = [ pkgs.age-plugin-yubikey ];

      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.secrets.${cfg.secretName}.path;
        CacheDirectory = "rustic";
        Environment = [
          "RUSTIC_CACHE_DIR=/var/cache/rustic"
          "RUSTIC_PASSWORD_COMMAND=${passwordCommand}"
        ];
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };

      script = ''
        set -euo pipefail
        ${lib.getExe pkgs.rustic} backup --init ${lib.escapeShellArgs persistenceRoots}
        ${lib.getExe pkgs.rustic} forget --prune ${lib.escapeShellArgs cfg.forgetArgs}
      '';
    };

    systemd.timers.rustic-backup = {
      description = "Schedule Rustic backup of impermanence data";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelaySec;
        Unit = "rustic-backup.service";
      };
    };
  };
}
