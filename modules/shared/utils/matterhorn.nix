{
  config,
  pkgs,
  ...
}:
let
  matterhornOpen = pkgs.writeShellApplication {
    name = "matterhorn-open";
    runtimeInputs = [ pkgs.attachment-open ];
    text = ''
      attachment-open "$1"
    '';
  };
in
{
  config = {
    home-manager.users.${config.cfi2017.user.name} = { lib, ... }: {
      home.packages = [ matterhornOpen ];

      # Matterhorn does not support layered configuration files. Update only
      # this setting so an existing, potentially private server/login config is
      # retained instead of replacing the whole file with a Nix store symlink.
      home.activation.configureMatterhornUrlOpener = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/matterhorn"
        config_file="$config_dir/config.ini"
        opener=${lib.escapeShellArg "${matterhornOpen}/bin/matterhorn-open"}

        $DRY_RUN_CMD mkdir -p "$config_dir"
        if [[ ! -e "$config_file" ]]; then
          $DRY_RUN_CMD touch "$config_file"
        fi

        if ${pkgs.gnugrep}/bin/grep -Eq '^[[:space:]#]*urlOpenCommand[[:space:]]*[:=]' "$config_file"; then
          $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i -E \
            "s|^[[:space:]#]*urlOpenCommand[[:space:]]*[:=].*$|urlOpenCommand = $opener|" \
            "$config_file"
        else
          if ! ${pkgs.gnugrep}/bin/grep -Eq '^\[mattermost\][[:space:]]*$' "$config_file"; then
            $DRY_RUN_CMD ${pkgs.coreutils}/bin/printf '%s\n' '[mattermost]' >> "$config_file"
          fi
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/printf '%s\n' "urlOpenCommand = $opener" >> "$config_file"
        fi
      '';
    };
  };
}
