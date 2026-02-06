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

      networking.nameservers = [
        # "1.1.1.1#one.one.one.one"
        # "1.0.0.1#one.one.one.one"
        "1.1.1.1"
        "8.8.8.8"
      ];

      services.resolved = {
        enable = true;
        dnssec = "false";
        domains = [ "~." ];
        fallbackDns = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        dnsovertls = "false";
      };

      programs.microsoft-azurevpnclient.enable = true;
    }
  ];
}
