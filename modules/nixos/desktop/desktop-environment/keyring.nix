{ config, lib, pkgs, ... }: {
  options.cfi2017.graphical.key_management = {
    enable = lib.mkEnableOption "key management";
  };

  config = lib.mkIf config.cfi2017.graphical.key_management.enable {
    environment.systemPackages = [ pkgs.gnome-keyring ];

    services = { gnome = { gnome-keyring.enable = true; }; };

    programs = { seahorse.enable = true; };

    security.pam.services = { sddm.enableGnomeKeyring.enable = true; };
  };
}
