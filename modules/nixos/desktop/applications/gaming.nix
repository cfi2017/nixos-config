{
  lib,
  config,
  ...
}:
{
  options = {
    cfi2017.gaming = {
      enable = lib.mkEnableOption "gaming packages";
    };
  };

  config = lib.mkIf config.cfi2017.development-packages.enable {
    programs = {
      steam.enable = true;
      gamemode.enable = true;
    };
  };
}
