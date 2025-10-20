{ config, pkgs, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.zen-browser = {
        enable = true;
        policies = let
          mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
            installation_mode = "force_installed";
          });
          in {
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
  };
}
