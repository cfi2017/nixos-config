{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./antigravity.nix
    ./gaming.nix
  ];

  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      home.packages = [
        pkgs.discord
        pkgs.google-chrome
        pkgs.obsidian
        pkgs.wireshark
        pkgs.headlamp
        pkgs.sable
        pkgs.signal-desktop
        # pkgs.libreoffice
        # pkgs.super-productivity
      ];
    };
  };
}
