# Shared System Configuration
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    # Allow unfree because we're not free :(
    nixpkgs.config = {
      allowUnfree = true;

      # citrix workspace is awful and doesn't update their linux packages
      permittedInsecurePackages = [
        "libsoup-2.74.3"
        "webkitgtk-2.42.4"
        "electron-39.8.10"
      ];
    };

    # timezone
    time.timeZone = config.cfi2017.timeZone;

    # locale
    i18n = {
      defaultLocale = "en_GB.UTF-8";
      extraLocaleSettings = {
        LC_ALL = "en_GB.UTF-8";
        LANGUAGE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };
      supportedLocales = [
        "de_CH.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
        "en_IE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
    };

    # internal CA (bao.k8s.swiss.dev)
    security.pki.certificates = [
      ''
        -----BEGIN CERTIFICATE-----
        MIIDSDCCAjCgAwIBAgIUJZWX3Epqj0IDObty2fUklHgFNVgwDQYJKoZIhvcNAQEL
        BQAwHDEaMBgGA1UEAxMRYmFvLms4cy5zd2lzcy5kZXYwHhcNMjUxMjE4MTAwNzA3
        WhcNMzUxMjE2MTAwNzM3WjAcMRowGAYDVQQDExFiYW8uazhzLnN3aXNzLmRldjCC
        ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMC/En2OXvjXtYFVAJbhdeJx
        99g5G8o7X0DafWI3rGyAmQrRxPSkFNOgifrLexpWgQluVNNWkDlefQkumLZ/MlVF
        sgr9292148omLwIKli8Gdo6KZ0Foa2Q2JeP72jnbkibmJ1c6H74dBqu20sZoPhpL
        9PXqIGOswKwBQSoPpdn8LSk53SS4+Go7XqytmIgqlceBawftyGwxiMndB27t2tt6
        fpSo3tS72OMObOImlWNngU8ei1zNOQxNgNvyxoU7zawbBP12QeWQDGg/ehABeG/d
        fdL0IfHWwpXVatayZWUBsAawSVlolMwey+HATiSMIR3iRTvLQ5YeHZOvO84d1OMC
        AwEAAaOBgTB/MA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
        DgQWBBQvBMAAsOMWqzpE0DbIrKKzsmPBcDAfBgNVHSMEGDAWgBQvBMAAsOMWqzpE
        0DbIrKKzsmPBcDAcBgNVHREEFTATghFiYW8uazhzLnN3aXNzLmRldjANBgkqhkiG
        9w0BAQsFAAOCAQEAnsaOpYL0CbvBN35eGK3moSzpc95ibYKqjiPZhv5jH0Bih6LY
        U5s+PfXjpalXk/V7BE6HKAnTX/o5rcU0lGEJTCOlJ5Ci80lYHn5G6PrMM2G4LvOc
        +wHrU58ZYbr9CnSJoCWlafzBUXaGaloh1dmWMwvrAk/OSQqs2RzRxg1wMUNAEKaN
        0sXebty4CH3KmRHXyEmhrcEkraFsKaQZnVyVvJKDwNvazRq5gl2o/yBxkB2vt1U9
        aO5DGkaEe6fM1jrIy1n/ndbI2FK/unppA7DXOEt4V3SR/TuyVNppWgoePgCN4q8c
        5DrAnPckFW8gtepXUQZ7VMdcPw38IthWeUbxPQ==
        -----END CERTIFICATE-----
      ''
    ];

    # zsh everywhere uwu
    programs.zsh.enable = true;
    programs.nix-ld.enable = true;
    environment.shells = with pkgs; [ zsh ];
    users.defaultUserShell = pkgs.zsh;

    # default editor
    environment.variables.EDITOR = config.cfi2017.user.editor;

    # fonts
    fonts = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        nerd-fonts.symbols-only
        nerd-fonts._0xproto
      ];
    };

    # nix config
    nix = {
      enable = true;
      package = pkgs.nix;
      settings = {
        trusted-users = [ config.cfi2017.user.name ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        auto-optimise-store = false;
      };

      # garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      optimise = {
        automatic = true;
        dates = "weekly";
      };
    };
  };
}
