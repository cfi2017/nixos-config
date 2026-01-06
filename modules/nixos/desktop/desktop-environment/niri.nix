{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  niri-session = "${pkgs.niri}/share/wayland-sessions";
in
{
  options.cfi2017.graphical.niri = {
    enable = lib.mkEnableOption "niriwm";
  };

  config = lib.mkIf config.cfi2017.graphical.niri.enable {
    environment.systemPackages = with pkgs; [ ];
  };
}
