{
  config,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          systemDataLinks = [
            {
              directory = "/etc/NetworkManager/system-connections/";
              # mode = "0700";
            }
          ];
        })
      ];
    })
    {
      services.netbird = {
        enable = true;
      };
    }
  ];
}
