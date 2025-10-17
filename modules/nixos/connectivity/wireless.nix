{ config, lib, ... }: {
  options.cfi2017.core.wireless.enable = lib.mkEnableOption "wireless";

  config = lib.mkIf config.cfi2017.core.wireless.enable {
    networking.wireless = { enable = true; };
    systemd.services."enable-wifi-on-boot" = {
      description = "Enable Wifi during boot";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "/run/current-system/sw/bin/rfkill unblock all";
        Type = "oneshot";
      };
    };
  };
}
