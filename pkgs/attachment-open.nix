{
  file,
  kitty,
  writeShellApplication,
  xdg-utils,
}:
let
  imagePreview = writeShellApplication {
    name = "attachment-image-preview";
    runtimeInputs = [ kitty ];
    text = ''
      image="$1"

      kitten icat --align center -- "$image"
      while IFS= read -r -s -n 1 key; do
        if [[ "$key" == q ]]; then
          exit 0
        fi
      done
    '';
  };
in
writeShellApplication {
  name = "attachment-open";
  runtimeInputs = [
    file
    kitty
    xdg-utils
  ];
  text = ''
    target="$1"

    if [[ -f "$target" ]] && [[ "$(file --brief --mime-type -- "$target")" == image/* ]]; then
      kitty \
        --detach \
        --class attachment-image-preview \
        --title "Image preview" \
        -- ${imagePreview}/bin/attachment-image-preview "$target"
    else
      xdg-open "$target" >/dev/null 2>&1 &
    fi
  '';
}
