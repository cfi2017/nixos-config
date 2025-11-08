{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeDataLinks = [
            {
              directory = ".zen";
              mode = "0700";
            }
            {
              directory = ".cache/zen";
              mode = "0700";
            }
          ];
        })
      ];
    })
    {
      home-manager.users.${config.cfi2017.user.name} = {
        programs.zen-browser = {
          enable = true;
          policies =
            let
              mkExtensionSettings = builtins.mapAttrs (
                _: pluginId: {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
                  installation_mode = "force_installed";
                }
              );
            in
            {
              AutofillAddressEnabled = false;
              AutofillCreditCardEnabled = false;
              DisableAppUpdate = true;
              DisableFeedbackCommands = true;
              DisableFirefoxStudies = true;
              DisablePocket = true;
              DisableTelemetry = true;
              DontCheckDefaultBrowser = true;
              NoDefaultBookmarks = true;
              OfferToSaveLogins = false;
              EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
              };
              ExtensionSettings = mkExtensionSettings {
                "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden";
                "uBlock0@raymondhill.net" = "uBlock Origin";
              };
            };
        };
      };
    }
  ];
}
