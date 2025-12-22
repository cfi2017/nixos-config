{
  config,
  pkgs,
  ...
}:
{
  imports = [
  ];

  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      home.packages = [
        pkgs.jetbrains.rust-rover
        pkgs.jetbrains.goland
        pkgs.discord
        pkgs.google-chrome
      ];
    };
  };
}
