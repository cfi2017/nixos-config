{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.cfi2017.graphical.xdg.enable = lib.mkEnableOption "xdg folders";

  config = lib.mkIf config.cfi2017.graphical.xdg.enable {
    cfi2017.core.zfs.homeDataLinks = [
      "documents"
      "music"
      "pictures"
      "videos"
      # Logseq's global config, graph metadata, plugins and preferences. Not
      # XDG-conformant (Logseq hardcodes ~/.logseq), but small and worth backing
      # up. Without persisting it the root rollback wipes it every boot, so
      # Logseq forgets which graph exists and you have to re-open it.
      ".logseq"
    ];
    cfi2017.core.zfs.homeCacheLinks = [
      "downloads"
      "code"
      # Logseq's Electron userData (XDG-conformant): window state plus the
      # localStorage that records the open/recent graph. Mostly rebuildable
      # cache, so it lives on the non-backed-up dataset -- but it still has to
      # survive reboots for Logseq to reopen the last graph.
      ".config/Logseq"
    ];

    # xdg = {
    #   portal = {
    #     enable = true;
    #     wlr.enable = true;
    #     extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    #     configPackages = with pkgs; [ xdg-desktop-portal-hyprland ];
    #   };
    # };

    home-manager.users.${config.cfi2017.user.name} =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          xdg-user-dirs
          xdg-utils
        ];
        xdg = {
          enable = true;
          portal = {
            enable = true;
            # wlr.enable = true;
            #
            # xdg-desktop-portal loads its backends from this home-manager profile
            # directory, so every backend we need at runtime must be listed here.
            # niri's screencast goes through xdg-desktop-portal-gnome (niri exposes
            # org.gnome.Mutter.ScreenCast, and the system-level programs.niri module
            # ships /etc/xdg/xdg-desktop-portal/niri-portals.conf routing ScreenCast
            # -> gnome). Without gnome+gtk here the profile only had hyprland+wlr, so
            # the ScreenCast portal interface never came up and screen sharing under
            # niri silently did nothing. gtk is the niri fallback backend; hyprland
            # (and wlr) stay for the Hyprland session.
            extraPortals = with pkgs; [
              xdg-desktop-portal-gnome
              xdg-desktop-portal-gtk
              xdg-desktop-portal-hyprland
              xdg-desktop-portal-wlr
            ];
            configPackages = with pkgs; [
              xdg-desktop-portal-hyprland
              xdg-desktop-portal-wlr
            ];
          };
          userDirs = {
            enable = true;
            # Keep exporting XDG_*_DIR into the session (upstream default flipped
            # true -> false).
            setSessionVariables = true;
            desktop = "$HOME/desktop";
            documents = "$HOME/documents";
            download = "$HOME/downloads";
            music = "$HOME/music";
            pictures = "$HOME/pictures";
            publicShare = "$HOME/desktop";
            templates = "$HOME/templates";
            videos = "$HOME/videos";
          };
        };
      };
  };
}
