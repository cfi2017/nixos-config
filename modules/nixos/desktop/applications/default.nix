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
        pkgs.discord
        pkgs.google-chrome
      ];
    };
  };
}
