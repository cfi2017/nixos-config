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
            {
              directory = "/var/lib/netbird/";
            }
          ];
        })
      ];
    })
    {
      services.netbird = {
        enable = true;
      };

      networking.nameservers = [
        # "1.1.1.1#one.one.one.one"
        # "1.0.0.1#one.one.one.one"
        "1.1.1.1"
        "8.8.8.8"
      ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ];
      };

      services.resolved = {
        enable = true;
        # Renamed in nixos-unstable: the individual options now live under the
        # freeform `settings.Resolve` table (written verbatim to resolved.conf).
        settings.Resolve = {
          DNSSEC = "false";
          Domains = [ "~." ];
          FallbackDNS = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          DNSOverTLS = "false";
        };
      };

      # programs.microsoft-azurevpnclient.enable = true;
    }
  ];
}
