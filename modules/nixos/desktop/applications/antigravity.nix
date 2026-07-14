{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.cfi2017.user.name;
  flavor = config.cfi2017.colorScheme.flavor; # e.g. "macchiato"
  accent = config.cfi2017.colorScheme.accent; # e.g. "peach"

  # Catppuccin's VS Code theme labels are title-cased ("Catppuccin Macchiato"),
  # while its icon-theme ids are the bare flavor ("catppuccin-macchiato").
  themeLabel =
    {
      latte = "Catppuccin Latte";
      frappe = "Catppuccin Frappé";
      macchiato = "Catppuccin Macchiato";
      mocha = "Catppuccin Mocha";
    }
    .${flavor};
  iconTheme = "catppuccin-${flavor}";

  themeExt = pkgs.vscode-extensions.catppuccin.catppuccin-vsc;
  iconsExt = pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons;

  # Antigravity is a VS Code fork (buildVscode). Its data folder is ~/.antigravity
  # (product.json dataFolderName), so extensions live in ~/.antigravity/extensions
  # and user config under ~/.config/Antigravity/User.
in
{
  config = {
    home-manager.users.${user} = hm: {
      home.packages = [ pkgs.antigravity ];

      # Manage settings.json declaratively (like the zed/kitty configs). This makes
      # the file a read-only symlink, so add future settings here rather than in the
      # app UI. The existing remote-SSH setting is preserved.
      #
      # mkDefault so this stays strictly additive: if another module (e.g. the work
      # flake) already writes this file, that definition wins instead of erroring.
      # home-manager cannot per-key merge two raw-file definitions, so whoever owns
      # the file owns all of it.
      xdg.configFile."Antigravity/User/settings.json".text = lib.mkDefault (
        builtins.toJSON {
          "workbench.colorTheme" = themeLabel;
          "workbench.iconTheme" = iconTheme;
          "catppuccin.accentColor" = accent;
          # Keep icon accents in sync with the theme accent.
          "catppuccin.syncWithIconPack" = true;
          # Preserve the user's existing remote setting.
          "remote.antigravitySSH.configFile" = "~/.ssh/config.ide";
        }
      );

      # Install the Catppuccin theme + icon extensions as *writable copies* rather
      # than read-only store symlinks. The theme extension recompiles its themes/*.json
      # at runtime whenever the catppuccin.* settings differ from its shipped default
      # (e.g. accentColor = peach), writing back into its own folder -- a symlink into
      # the Nix store makes that fail with EROFS. Copying dereferences the store paths
      # into ~/.antigravity/extensions (a writable dir) so the recompile succeeds.
      #
      # The copy is rebuilt every activation (rm + cp) so it tracks package updates.
      # extensions.json / .obsolete are the VS Code extension cache; dropping them
      # forces Antigravity to rescan the folder and pick up the refreshed copies.
      home.activation.antigravityExtensions = hm.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        extDir="$HOME/.antigravity/extensions"
        run mkdir -p "$extDir"
        for ext in catppuccin.catppuccin-vsc catppuccin.catppuccin-vsc-icons; do
          run rm -rf "$extDir/$ext"
        done
        run cp -rL --no-preserve=mode \
          "${themeExt}/share/vscode/extensions/catppuccin.catppuccin-vsc" "$extDir/"
        run cp -rL --no-preserve=mode \
          "${iconsExt}/share/vscode/extensions/catppuccin.catppuccin-vsc-icons" "$extDir/"
        run chmod -R u+w "$extDir/catppuccin.catppuccin-vsc" "$extDir/catppuccin.catppuccin-vsc-icons"
        run rm -f "$extDir/extensions.json" "$extDir/.obsolete"
      '';
    };
  };
}
