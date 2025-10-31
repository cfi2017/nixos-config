# Shared System Configuration

{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    # Allow unfree because we're not free :(
    nixpkgs.config = {
      allowUnfree = true;
    };

    # timezone
    time.timeZone = config.cfi2017.timeZone;

    # zsh everywhere uwu
    programs.zsh.enable = true;
    programs.nix-ld.enable = true;
    environment.shells = with pkgs; [ zsh ];
    users.defaultUserShell = pkgs.zsh;

    # default editor
    environment.variables.EDITOR = config.cfi2017.user.editor;

    # fonts
    fonts = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        nerd-fonts.symbols-only
        nerd-fonts._0xproto
      ];
    };

    # nix config
    nix = {
      enable = true;
      package = pkgs.nix;
      settings = {
        trusted-users = [ config.cfi2017.user.name ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        auto-optimise-store = false;
      };

      # garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      optimise = {
        automatic = true;
        dates = "weekly";
      };
    };

  };
}
