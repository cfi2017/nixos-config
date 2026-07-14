{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./antigravity.nix
  ];

  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      home.packages = [
        pkgs.discord
        pkgs.google-chrome
        pkgs.obsidian
        pkgs.wireshark
        pkgs.headlamp
        pkgs.libreoffice
      ];
    };
  };
}
